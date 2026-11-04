class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.10.21"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.21/agito-relay-0.10.21-aarch64-apple-darwin.tar.gz"
      sha256 "7dcf759af125c8c5689f1502225340cb00c67ac3bed77c8c1b1b67fc3bc2ee30"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.21/agito-relay-0.10.21-x86_64-apple-darwin.tar.gz"
      sha256 "0bedff26e05689e621be2161836334a585188931a12159dd874a5c0fd6ad4bb5"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.21/agito-relay-0.10.21-aarch64-unknown-linux-musl.tar.gz"
      sha256 "d99b3843ab4631dbe8adfe97ed45bd7264effb9673cbcd993a6eeb28bb0d4a23"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.21/agito-relay-0.10.21-x86_64-unknown-linux-musl.tar.gz"
      sha256 "2a4c4072cac293805cfdb853a9e4e64f08835a4a914ebc13462ce570fe66471e"
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
