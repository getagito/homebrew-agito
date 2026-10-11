class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.9.5"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.9.5/agito-relay-0.9.5-aarch64-apple-darwin.tar.gz"
      sha256 "91f2fc3307798bb745ecbda59a737857435c283302a3f60aa8349c355e78fc1c"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.9.5/agito-relay-0.9.5-x86_64-apple-darwin.tar.gz"
      sha256 "f13bbd45b5ae843d09bb4cd5f44ae3aef4b933391451d745135098ec2f597481"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.9.5/agito-relay-0.9.5-aarch64-unknown-linux-musl.tar.gz"
      sha256 "0ac0ed2e3a2bfb961413ebe96d6b738e2d551320ccb8a2e3699e0a00aca85386"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.9.5/agito-relay-0.9.5-x86_64-unknown-linux-musl.tar.gz"
      sha256 "20d800e729678ecd7a484c1c0b428d05257acdd727043b803c1cdd2c75ab8584"
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
