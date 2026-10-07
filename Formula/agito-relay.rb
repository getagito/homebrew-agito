class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.9.0"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.9.0/agito-relay-0.9.0-aarch64-apple-darwin.tar.gz"
      sha256 "7481a5a01c0c784e6d1fb9fa2fe8c3c1aba5c77d6fbbcc0585d8fe27df9cc8e7"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.9.0/agito-relay-0.9.0-x86_64-apple-darwin.tar.gz"
      sha256 "856e6d3c478162b45089d177c1494bd6aaa35f6e4d265c80b2e900cad1cf8d0c"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.9.0/agito-relay-0.9.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "ca0f888c329f165b0c79fb9e4710136382389dc265940e0eaa9d6709278b3c44"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.9.0/agito-relay-0.9.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "42eed7812b2ea8632ae824244ee263d4f478454683c5a4fe25794e613cb9bff0"
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
