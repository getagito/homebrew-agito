class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.7.0"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.7.0/agito-relay-0.7.0-aarch64-apple-darwin.tar.gz"
      sha256 "99cf07a16de493b66dffcf76d2a5fc4a8a3720ddd52e7dad44705044108ab3a0"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.7.0/agito-relay-0.7.0-x86_64-apple-darwin.tar.gz"
      sha256 "126b12b5f2d6d2f85cf3a5a7ae46301acd4bb227a52751c0c466ad31a16878ab"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.7.0/agito-relay-0.7.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "b074918652513e143dd9a45f0b6d363553e435ea2d0a23607f79194510a0a4a7"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.7.0/agito-relay-0.7.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "679491574240142910027dd917748742cf19c0272ee635aa7e0c8643faf41f9e"
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
