class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.8.0"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.8.0/agito-relay-0.8.0-aarch64-apple-darwin.tar.gz"
      sha256 "186f9bbf02bde7e7296910e053657a470a17cab3d9b4783707c520f1bbc1b205"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.8.0/agito-relay-0.8.0-x86_64-apple-darwin.tar.gz"
      sha256 "884bce5970bb0cc0949aa5a9b62965b7b7973990fdf36f4e257845e521bde6c2"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.8.0/agito-relay-0.8.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "c7ffd621dcc4b9c31b992aa006ff941da33b358f9d3d4669e122056e37214dc9"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.8.0/agito-relay-0.8.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "0c638b37c1baf95dbfb990eb1b972cf953a978622df806ba364949545fac9e91"
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
