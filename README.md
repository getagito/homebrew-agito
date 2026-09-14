# Agito Homebrew Tap

`agito-relay` runs on your development machine and sends coding agent status from Herdr and tmux to [Agito](https://getagito.dev) push notifications.

```bash
brew install getagito/agito/agito-relay
brew services start agito-relay
```

Then turn on notifications in the Agito app. It pairs with this machine over SSH.

## Without Homebrew

```bash
curl -fsSL https://raw.githubusercontent.com/getagito/homebrew-agito/main/install.sh | sh
```

The script downloads the release for your platform, verifies its sha256, installs `~/.local/bin/agito-relay` (no sudo), and keeps it running as a systemd user service (Linux) or a LaunchAgent (macOS). Run it again to restart or update. On Linux it offers to run `loginctl enable-linger` so the relay keeps running after you log out.

- Supported platforms: macOS (Apple silicon, Intel) and Linux (arm64, x86_64).
- On Linux, run `loginctl enable-linger "$USER"` so the relay keeps running after you log out.
- The relay uploads nothing until at least one device has subscribed to this machine. It never uploads terminal output, prompts or code.
