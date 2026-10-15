class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.10.3"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.3/agito-relay-0.10.3-aarch64-apple-darwin.tar.gz"
      sha256 "ba0d0c7915f36870b2a46b41b62ec8e09bcede8de5596d64f3480ed52b4d3f21"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.3/agito-relay-0.10.3-x86_64-apple-darwin.tar.gz"
      sha256 "e05353087704f3d263502705bede6144c35ecb16dbe87266d67ff68b88931e1a"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.3/agito-relay-0.10.3-aarch64-unknown-linux-musl.tar.gz"
      sha256 "0e22a47bcdd85dea37f2fdbb32187dfa09e0774a6e8135fefa5476396746e41c"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.3/agito-relay-0.10.3-x86_64-unknown-linux-musl.tar.gz"
      sha256 "05a270fb2ae2b0bcba8530bfb89185984f980e0e5c5c527cc9aea2b507e55bba"
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
