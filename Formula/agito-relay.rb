class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.10.10"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.10/agito-relay-0.10.10-aarch64-apple-darwin.tar.gz"
      sha256 "6c85f6e3b643a0480f4492c11d40469a259aee4688a1d985aad9ab5984cd2c3c"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.10/agito-relay-0.10.10-x86_64-apple-darwin.tar.gz"
      sha256 "6d5fa7d0c0e2a7f5f83247cc74c2bfff3b00d39f7a5786f5742543693f1d7561"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.10/agito-relay-0.10.10-aarch64-unknown-linux-musl.tar.gz"
      sha256 "cd08ff61f834ac20f77aa315d06edabae59e58166e276360aea1a52b07818e14"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.10/agito-relay-0.10.10-x86_64-unknown-linux-musl.tar.gz"
      sha256 "89007572ddb1b6482364a00d9cbcb7003581a241c9b3f61cdbbda46cead3da1d"
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
