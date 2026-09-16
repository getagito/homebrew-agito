class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.3.4"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.3.4/agito-relay-0.3.4-aarch64-apple-darwin.tar.gz"
      sha256 "19fdc66b05721958f238906464781dfd18341d2281da6ddadd920e822050e2a6"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.3.4/agito-relay-0.3.4-x86_64-apple-darwin.tar.gz"
      sha256 "98e00ced606ecd78d2b2f8f3369df2a1fa24af285ccad07b14ff0328a00ee9be"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.3.4/agito-relay-0.3.4-aarch64-unknown-linux-musl.tar.gz"
      sha256 "1735277b8dda3aa5e97c0f524e019575859f6dc49cd99ff77dcccc33b10bb962"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.3.4/agito-relay-0.3.4-x86_64-unknown-linux-musl.tar.gz"
      sha256 "f362e7fbdea9baf0f8e61340de1f4307aad7040468dbd6beffe43e45df91d109"
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
