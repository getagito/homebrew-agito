class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.10.17"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.17/agito-relay-0.10.17-aarch64-apple-darwin.tar.gz"
      sha256 "d59e4c93ef9b60cbf4e0d41038f33b6e95713f160a799748e21e86fa740804a8"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.17/agito-relay-0.10.17-x86_64-apple-darwin.tar.gz"
      sha256 "448b97f8ff105c9dd63b69d2033d4638a93e8112977d8b15a34e9cb3a02dd53e"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.17/agito-relay-0.10.17-aarch64-unknown-linux-musl.tar.gz"
      sha256 "8931eab96ebd89468ee6129528835bf0bfcb53d9310c3eb23d258d5c00d31ddd"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.17/agito-relay-0.10.17-x86_64-unknown-linux-musl.tar.gz"
      sha256 "f4edbb1355513875b188e0e537dea4a4fb6dbbb05be44291fba06a8c9495a710"
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
