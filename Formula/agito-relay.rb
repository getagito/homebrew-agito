class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.4.3"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.4.3/agito-relay-0.4.3-aarch64-apple-darwin.tar.gz"
      sha256 "0a7bdb63b12c530c1927d75ef3a2c00f2f2d49d1b6fbf28f2cde528234974792"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.4.3/agito-relay-0.4.3-x86_64-apple-darwin.tar.gz"
      sha256 "3056c390e5c6efef33f0113f9b18fc52ee95e7762e6e259b3300e70b0707b2a5"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.4.3/agito-relay-0.4.3-aarch64-unknown-linux-musl.tar.gz"
      sha256 "3cb2cf691868c346b1b3e2b18b12a0b067d3f532698270708de1e87f7a3cf3a6"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.4.3/agito-relay-0.4.3-x86_64-unknown-linux-musl.tar.gz"
      sha256 "85ad27dc274899a9d70590ec28da153b9c0b88afed0495aa09cf5c0953a1080b"
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
