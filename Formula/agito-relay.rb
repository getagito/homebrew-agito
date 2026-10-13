class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.10.1"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.1/agito-relay-0.10.1-aarch64-apple-darwin.tar.gz"
      sha256 "88d21f9709900125680089f95897ef62cf2ae76a05df44f4c493c42db8cd2434"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.1/agito-relay-0.10.1-x86_64-apple-darwin.tar.gz"
      sha256 "d0fc224bba70c2eff5a2dbc5bc74dcccdf56cadd0a2ba16b3ca84979e133d90f"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.1/agito-relay-0.10.1-aarch64-unknown-linux-musl.tar.gz"
      sha256 "c5388846bef3b8372515b5b6d11318bc0bb7a6ef56a117cb21e26215bd8f7d71"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.1/agito-relay-0.10.1-x86_64-unknown-linux-musl.tar.gz"
      sha256 "30d0919de0e8216a3614c22128e3dc975fe784dac836af1d4d9e412df149f8f1"
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
