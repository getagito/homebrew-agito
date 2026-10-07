class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.9.2"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.9.2/agito-relay-0.9.2-aarch64-apple-darwin.tar.gz"
      sha256 "690c728e98ad1a57f99d9feebee5fbe80beabbb06d8fd0650f041c2f467d8a18"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.9.2/agito-relay-0.9.2-x86_64-apple-darwin.tar.gz"
      sha256 "5458b3db76f1f73f281ecdbd8ead767d7d5091a1931c39f9c8fc7e42474aa06b"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.9.2/agito-relay-0.9.2-aarch64-unknown-linux-musl.tar.gz"
      sha256 "aa4dcda843c3fd82fca6fbd2ed2ee8abd36656887f42f51ac4a3449dfc8ffced"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.9.2/agito-relay-0.9.2-x86_64-unknown-linux-musl.tar.gz"
      sha256 "5ad3dc3f8ef8ebaec3a97a8bb7ae9622e878a22eaa1cd6da42aa07ad07717aa3"
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
