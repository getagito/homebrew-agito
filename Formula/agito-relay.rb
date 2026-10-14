class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.10.2"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.2/agito-relay-0.10.2-aarch64-apple-darwin.tar.gz"
      sha256 "dc88723256ac88e1b0f01c590a44d4190f4f6ae48fe369afb1d0498eb8558d2d"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.2/agito-relay-0.10.2-x86_64-apple-darwin.tar.gz"
      sha256 "b9297cc0633a7ddc0908cfb8a4a30a6f6aa06c14822948016a418de3661e5a33"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.2/agito-relay-0.10.2-aarch64-unknown-linux-musl.tar.gz"
      sha256 "2769784625a33e3f17b8d01e2215195e473ae640a7e38c0eb346ee028311dc74"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.2/agito-relay-0.10.2-x86_64-unknown-linux-musl.tar.gz"
      sha256 "0b0f45f8e2f6d98f85ccbefcabee00d9e617768a2865900680d6248b67e0beb0"
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
