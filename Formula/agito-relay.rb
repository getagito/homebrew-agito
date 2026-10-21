class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.10.13"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.13/agito-relay-0.10.13-aarch64-apple-darwin.tar.gz"
      sha256 "fdb03a3fdbe862d7206590559a79e6383197598c483be10114916e4e6c449b01"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.13/agito-relay-0.10.13-x86_64-apple-darwin.tar.gz"
      sha256 "0f13fc4e7e874032cc97e38997597c1bfb976b82a01e9d299ecf8efcbc0ce687"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.13/agito-relay-0.10.13-aarch64-unknown-linux-musl.tar.gz"
      sha256 "7e0ac088bd1bc4e504a3c8ca69e3e1d2689d5543a8acad5b022afe68b9a9d1fe"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.13/agito-relay-0.10.13-x86_64-unknown-linux-musl.tar.gz"
      sha256 "58d1b3b5f4c943bedc47e3c2f16e79f9d2bd4622e43a35e3955a9354e6e72dbf"
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
