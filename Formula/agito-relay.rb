class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.9.1"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.9.1/agito-relay-0.9.1-aarch64-apple-darwin.tar.gz"
      sha256 "fc3d2a7fc6b7f237e7b19fdef35066ee422249d417972e204be08bb42351d975"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.9.1/agito-relay-0.9.1-x86_64-apple-darwin.tar.gz"
      sha256 "029e6498cc962b0de9cf6e76531313f3ad5a8f12c30e6d141543a5298467f6a7"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.9.1/agito-relay-0.9.1-aarch64-unknown-linux-musl.tar.gz"
      sha256 "ccbe9b3f613c1def851e72d4c0ae50b6018f4004108267b92d7d69015bb91cd0"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.9.1/agito-relay-0.9.1-x86_64-unknown-linux-musl.tar.gz"
      sha256 "1023eca7af1cedcd38d0cd9470e89d76a53a4269f87b83b8dfb0d8defc297524"
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
