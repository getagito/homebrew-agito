class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.10.14"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.14/agito-relay-0.10.14-aarch64-apple-darwin.tar.gz"
      sha256 "39c3794f1eaf1be5bfe97f9d3bbceb0ec4a4d94e31f5764c262e123e8267a6ea"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.14/agito-relay-0.10.14-x86_64-apple-darwin.tar.gz"
      sha256 "b9dd55c69ff82f2b44371eb19556e3c997cfc847be8eb8d09e9824b77f3530ec"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.14/agito-relay-0.10.14-aarch64-unknown-linux-musl.tar.gz"
      sha256 "07d4a25a2b815d95ff9bbdef4493a4640949d35a7c8a3af6405e4c58e0705ddc"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.14/agito-relay-0.10.14-x86_64-unknown-linux-musl.tar.gz"
      sha256 "7c819b8cb7a66a3899d0d42b45d9e5faa4ded5519ee689e4f2caaeaea765bee2"
    end
  end

  def install
    bin.install "agito-relay"
    pkgshare.install "claude-hooks.json", "merge-claude-hooks.mjs"
  end

  service do
    run [opt_bin/"agito-relay"]
    keep_alive true
    # 不设 RUST_LOG 时 relay 只输出 error，注册失败等 warn 会被过滤掉。
    environment_variables PATH: std_service_path_env, RUST_LOG: "warn"
    log_path var/"log/agito-relay.log"
    error_log_path var/"log/agito-relay.log"
  end

  def caveats
    <<~EOS
      Start the relay and keep it running in the background:
        brew services start agito-relay

      On Linux, keep it running after you log out of SSH:
        loginctl enable-linger "$USER"

      Then add this machine in the Agito app (prints a QR code to scan with your phone):
        agito-relay host setup

      Finally turn on notifications in the Agito app. It connects to this machine over SSH.

      Herdr sessions work without extra setup. For Claude Code running directly in tmux,
      merge the hooks into your Claude settings (prints the merged file, does not overwrite):
        node #{pkgshare}/merge-claude-hooks.mjs ~/.claude/settings.json
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/agito-relay --version")
  end
end
