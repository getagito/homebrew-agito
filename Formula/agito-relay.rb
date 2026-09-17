class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.3.8"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.3.8/agito-relay-0.3.8-aarch64-apple-darwin.tar.gz"
      sha256 "6a2fb5ca0da3cadd7e39a79e0f46ecafeb73be47e7a508d2b794deb999740bee"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.3.8/agito-relay-0.3.8-x86_64-apple-darwin.tar.gz"
      sha256 "516e8afdc593640bdebcfa8ca07b44daeca460cfed6a7b98e9da192434cdf314"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.3.8/agito-relay-0.3.8-aarch64-unknown-linux-musl.tar.gz"
      sha256 "69e4860e83dcb7da02968635946f0babac79885f4a61f3a7712bbd433cd25d94"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.3.8/agito-relay-0.3.8-x86_64-unknown-linux-musl.tar.gz"
      sha256 "fa1edeefdf1f514f288374daa4c57059f366d3b0ae242e2128f91f04cb4f0c87"
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
