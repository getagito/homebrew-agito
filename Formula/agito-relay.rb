class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.9.4"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.9.4/agito-relay-0.9.4-aarch64-apple-darwin.tar.gz"
      sha256 "7733ee44e9236b6ad9724621563aecc07dbeb049f94adff65d16e27b3468a48d"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.9.4/agito-relay-0.9.4-x86_64-apple-darwin.tar.gz"
      sha256 "aa053e055a328ccde048d3c757be63ed22418d64932d9a8c2927f9add42b868a"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.9.4/agito-relay-0.9.4-aarch64-unknown-linux-musl.tar.gz"
      sha256 "5d5a7f376f5e0d0778a6c2e2689dfb62a943f5224778c03195abe57e3e131c6d"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.9.4/agito-relay-0.9.4-x86_64-unknown-linux-musl.tar.gz"
      sha256 "2984d1f7511d6871034a8ea76381fcba6926dfdfd2d6d1f05935b5416f39f6ac"
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
