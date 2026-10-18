class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.10.6"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.6/agito-relay-0.10.6-aarch64-apple-darwin.tar.gz"
      sha256 "477c6ce39295477d5b60ca6c9fb181fd54bb881c935cd87811a94a678d66f2b6"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.6/agito-relay-0.10.6-x86_64-apple-darwin.tar.gz"
      sha256 "9835339d68999679a878e89dddd7ca35b334eecd03351ba30301aefa65da507b"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.6/agito-relay-0.10.6-aarch64-unknown-linux-musl.tar.gz"
      sha256 "1529af0132e33d843bc5c78c24b2b7292debe0eb09a47c5f627f0e8a7d696ccd"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.6/agito-relay-0.10.6-x86_64-unknown-linux-musl.tar.gz"
      sha256 "5b45fa8f665317f6dde84d48cf44a34604af60e8c69eb241478bc55eb7454b13"
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
