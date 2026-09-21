class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.4.1"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.4.1/agito-relay-0.4.1-aarch64-apple-darwin.tar.gz"
      sha256 "441262e50c5575943d9e3e3478bf3a21edb73b0f1bff547c0028088a53d1ea2e"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.4.1/agito-relay-0.4.1-x86_64-apple-darwin.tar.gz"
      sha256 "3984760126ed0c2a159aa8e9aaab4d1a78fd87b3d040203ef75e06471d3d4655"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.4.1/agito-relay-0.4.1-aarch64-unknown-linux-musl.tar.gz"
      sha256 "3422d22d6992772b2920d1c5e36d71a427c032ab7778b03410d887632b0d9f00"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.4.1/agito-relay-0.4.1-x86_64-unknown-linux-musl.tar.gz"
      sha256 "5ec332ecbd5e435c8b793d0b6927229a0a6f1ed06cf182be03ee2cf69ad2c289"
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
