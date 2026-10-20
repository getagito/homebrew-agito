class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.10.11"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.11/agito-relay-0.10.11-aarch64-apple-darwin.tar.gz"
      sha256 "d0e43c92311b28d1058ed4d17206bbf1fa9eec985bc4aac7df368f13ce3f02bc"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.11/agito-relay-0.10.11-x86_64-apple-darwin.tar.gz"
      sha256 "49d189c442581813393b30434cd7efd70699f8047d11277592302b3bf174cd92"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.11/agito-relay-0.10.11-aarch64-unknown-linux-musl.tar.gz"
      sha256 "0b7894d5932f28879df6f0e7acec306bc9fb16c00e2b8cc1014fcbeb47743b58"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.11/agito-relay-0.10.11-x86_64-unknown-linux-musl.tar.gz"
      sha256 "d4c38c9fbec37ddf29ecc6460b6982d0fd2bc48c6e9df0cd537773656c18e49a"
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
