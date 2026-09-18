class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.3.9"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.3.9/agito-relay-0.3.9-aarch64-apple-darwin.tar.gz"
      sha256 "e93da034505dc8c61e8e94a9b4b352fe223d1441eaef3bafd6c943bba7e15f0d"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.3.9/agito-relay-0.3.9-x86_64-apple-darwin.tar.gz"
      sha256 "084f589f3872003d319d6255d06865f3f96bf4fc5864a3deb1a825c6925f918d"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.3.9/agito-relay-0.3.9-aarch64-unknown-linux-musl.tar.gz"
      sha256 "116dc978230f8adf2f85cb381a55675b9027e3cd4bbfe3ddeb423abcc1e461e0"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.3.9/agito-relay-0.3.9-x86_64-unknown-linux-musl.tar.gz"
      sha256 "c174acd93ca2dc2340080b9cec9d322994c8b7aa358fa8e386a9ac9e7d7a285d"
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

      Then turn on notifications in the Agito app. It pairs with this machine over SSH.

      Herdr sessions work without extra setup. For Claude Code running directly in tmux,
      merge the hooks into your Claude settings (prints the merged file, does not overwrite):
        node #{pkgshare}/merge-claude-hooks.mjs ~/.claude/settings.json
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/agito-relay --version")
  end
end
