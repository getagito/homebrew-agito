class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.10.7"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.7/agito-relay-0.10.7-aarch64-apple-darwin.tar.gz"
      sha256 "bf61ea0c4c812e7c6bcfb33d35f582023495c328d5025a92d8ae5eb4e9f01c91"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.7/agito-relay-0.10.7-x86_64-apple-darwin.tar.gz"
      sha256 "522a50a5e427c17e824ff4e5d0ed7fdfa0585ec63d1246b8b1c69f1d2b310578"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.7/agito-relay-0.10.7-aarch64-unknown-linux-musl.tar.gz"
      sha256 "2f65d4f740accfb5c98e45601ddb9d74c9c34ff88ae6171078f03d2391e269be"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.7/agito-relay-0.10.7-x86_64-unknown-linux-musl.tar.gz"
      sha256 "e1b5341bbcd070e3ff620008644b160a1f4ff6aa356aeddf759dac20d0dd179a"
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
