class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.4.4"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.4.4/agito-relay-0.4.4-aarch64-apple-darwin.tar.gz"
      sha256 "7e951fa7e1e08981780e5d43abc36aade1d1f7d043cd3854dbc4acf0f8834a1e"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.4.4/agito-relay-0.4.4-x86_64-apple-darwin.tar.gz"
      sha256 "8db35d9d930492cafd2a79088e532d8c1a0eee84087c273ecc3b3ed448db92e1"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.4.4/agito-relay-0.4.4-aarch64-unknown-linux-musl.tar.gz"
      sha256 "3419a4d8723d8f19817e004d687425a2e90d7e9e499a579083b0e7bec9f11d8b"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.4.4/agito-relay-0.4.4-x86_64-unknown-linux-musl.tar.gz"
      sha256 "27967cc3a8f5caff8a1a4877ff148771c5dc5b2be192350c7becd26b46799e77"
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
