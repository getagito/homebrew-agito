class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.4.0"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.4.0/agito-relay-0.4.0-aarch64-apple-darwin.tar.gz"
      sha256 "ebd6c3c333c57c110a271d7ea12c695ec0848d005132040e8dfbfb357b445121"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.4.0/agito-relay-0.4.0-x86_64-apple-darwin.tar.gz"
      sha256 "7b82ae185a66bc6d19f7003d903d5f88cc68fa61d3898fa9bd8180e6738aa8e9"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.4.0/agito-relay-0.4.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "d799737c34485400414746a243203ffe2cbf6d9e45687de4403b1e1ab53c7e50"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.4.0/agito-relay-0.4.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "6961e2b26824b0109caeb88171338d0d9f3017086955c2a933ed7419abf32e1f"
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
