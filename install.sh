#!/bin/sh
# Install or update agito-relay without Homebrew.
#
#   curl -fsSL https://raw.githubusercontent.com/getagito/homebrew-agito/main/install.sh | sh
#
# - Installs to ~/.local/bin/agito-relay (no sudo).
# - Linux: systemd user service. macOS: LaunchAgent.
# - Safe to run again: restarts the service, and updates when a newer release exists.
# - If Homebrew already manages agito-relay, it only prints the Homebrew command.
set -eu

REPO="getagito/homebrew-agito"
BASE="https://github.com/$REPO/releases/latest/download"
BIN_DIR="$HOME/.local/bin"
SHARE_DIR="$HOME/.local/share/agito"
LABEL="dev.agito.relay"

say() { printf '==> %s\n' "$*"; }
fail() { printf 'agito-relay install: %s\n' "$*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || fail "$1 is required"; }

os=$(uname -s)
arch=$(uname -m)
case "$os" in
  Darwin) os_target=apple-darwin ;;
  Linux) os_target=unknown-linux-musl ;;
  *) fail "unsupported operating system: $os" ;;
esac
case "$arch" in
  arm64 | aarch64) arch_target=aarch64 ;;
  x86_64 | amd64) arch_target=x86_64 ;;
  *) fail "unsupported CPU architecture: $arch" ;;
esac
target="$arch_target-$os_target"

if command -v brew >/dev/null 2>&1 && brew list agito-relay >/dev/null 2>&1; then
  say "agito-relay is managed by Homebrew on this machine."
  printf '    Update it with: brew upgrade agito-relay && brew services restart agito-relay\n'
  exit 0
fi

need curl
need tar
if command -v shasum >/dev/null 2>&1; then
  sha256() { shasum -a 256 "$1" | awk '{print $1}'; }
elif command -v sha256sum >/dev/null 2>&1; then
  sha256() { sha256sum "$1" | awk '{print $1}'; }
else
  fail "shasum or sha256sum is required"
fi

tmp=$(mktemp -d 2>/dev/null || mktemp -d -t agito-relay)
trap 'rm -rf "$tmp"' EXIT

curl -fsSL "$BASE/SHA256SUMS" -o "$tmp/SHA256SUMS" || fail "could not download the release checksums"
line=$(grep " agito-relay-.*-$target\.tar\.gz\$" "$tmp/SHA256SUMS" | head -n 1 || true)
[ -n "$line" ] || fail "no release package for $target"
expected=$(printf '%s\n' "$line" | awk '{print $1}')
file=$(printf '%s\n' "$line" | awk '{print $2}')
version=$(printf '%s\n' "$file" | sed -e 's/^agito-relay-//' -e "s/-$target\\.tar\\.gz\$//")

installed=""
if [ -x "$BIN_DIR/agito-relay" ]; then
  installed=$("$BIN_DIR/agito-relay" --version 2>/dev/null | awk '{print $2}' || true)
fi

say "$os $arch · agito-relay $version"
if [ "$installed" = "$version" ]; then
  say "agito-relay $version is already installed"
else
  say "Downloading $file"
  curl -fsSL "$BASE/$file" -o "$tmp/$file" || fail "could not download $file"
  [ "$(sha256 "$tmp/$file")" = "$expected" ] || fail "sha256 mismatch for $file"
  say "sha256 verified"
  mkdir -p "$tmp/package" "$BIN_DIR" "$SHARE_DIR"
  # GNU tar warns about macOS extended headers in older packages; only show tar output when it fails.
  tar -xzf "$tmp/$file" -C "$tmp/package" 2>"$tmp/tar.log" || { cat "$tmp/tar.log" >&2; fail "could not unpack $file"; }
  # Replace atomically so a running relay keeps its old inode until the restart below.
  cp "$tmp/package/agito-relay" "$BIN_DIR/.agito-relay.new"
  chmod 0755 "$BIN_DIR/.agito-relay.new"
  mv -f "$BIN_DIR/.agito-relay.new" "$BIN_DIR/agito-relay"
  cp "$tmp/package/claude-hooks.json" "$tmp/package/merge-claude-hooks.mjs" "$SHARE_DIR/"
  say "Installed $BIN_DIR/agito-relay"
fi

if [ "$os" = Linux ]; then
  need systemctl
  unit_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
  mkdir -p "$unit_dir"
  cat > "$unit_dir/agito-relay.service" <<EOF
[Unit]
Description=Agito relay
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
Environment=RUST_LOG=warn
EnvironmentFile=-%h/.config/agito/relay.env
ExecStart=$BIN_DIR/agito-relay
Restart=on-failure
RestartSec=5
KillSignal=SIGINT
UMask=0077

[Install]
WantedBy=default.target
EOF
  systemctl --user daemon-reload || fail "systemctl --user is not available in this session"
  systemctl --user enable agito-relay >/dev/null 2>&1
  systemctl --user restart agito-relay
  say "systemctl --user enable --now agito-relay"

  user=$(id -un)
  linger=$(loginctl show-user "$user" -p Linger 2>/dev/null | sed 's/^Linger=//' || true)
  if [ "$linger" != yes ]; then
    printf 'Keep agito-relay running after you log out of SSH?\n'
    printf 'This runs: loginctl enable-linger %s  [y/N] ' "$user"
    answer=""
    # curl | sh uses stdin for the script itself, so read the answer from the terminal.
    if (: </dev/tty) 2>/dev/null; then
      read -r answer </dev/tty || answer=""
    else
      printf '\n'
    fi
    case "$answer" in
      y | Y | yes | YES)
        loginctl enable-linger "$user" || printf 'Could not enable linger. Run it yourself: loginctl enable-linger %s\n' "$user"
        ;;
      *)
        printf 'Skipped. Push notifications stop when you log out until you run: loginctl enable-linger %s\n' "$user"
        ;;
    esac
  fi
  log_hint="journalctl --user -u agito-relay -n 20"
else
  agents="$HOME/Library/LaunchAgents"
  plist="$agents/$LABEL.plist"
  mkdir -p "$agents" "$HOME/Library/Logs"
  cat > "$plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key><array><string>$BIN_DIR/agito-relay</string></array>
  <key>EnvironmentVariables</key>
  <dict>
    <key>HOME</key><string>$HOME</string>
    <key>PATH</key><string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin</string>
    <key>RUST_LOG</key><string>warn</string>
  </dict>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
  <key>ThrottleInterval</key><integer>5</integer>
  <key>StandardErrorPath</key><string>$HOME/Library/Logs/agito-relay.log</string>
</dict>
</plist>
EOF
  uid=$(id -u)
  domain="gui/$uid"
  launchctl print "$domain" >/dev/null 2>&1 || domain="user/$uid"
  launchctl bootout "$domain/$LABEL" >/dev/null 2>&1 || true
  attempt=0
  until launchctl bootstrap "$domain" "$plist" 2>/dev/null; do
    attempt=$((attempt + 1))
    [ "$attempt" -lt 5 ] || fail "launchctl bootstrap $domain $plist failed"
    sleep 1
  done
  say "launchctl bootstrap $domain $LABEL"
  log_hint="tail -n 20 $HOME/Library/Logs/agito-relay.log"
fi

attempt=0
while [ "$attempt" -lt 10 ]; do
  if printf '{"method":"info"}\n' | "$BIN_DIR/agito-relay" rpc >/dev/null 2>&1; then
    printf '✓ agito-relay %s is running. Return to Agito › Settings › Notifications.\n' "$version"
    exit 0
  fi
  attempt=$((attempt + 1))
  sleep 1
done
fail "agito-relay did not start. Check the log: $log_hint"
