class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.10.4"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.4/agito-relay-0.10.4-aarch64-apple-darwin.tar.gz"
      sha256 "daf7d518b6eddf91ce94b3ea724bee5e677ced2f2396d352b77793150b5809df"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.4/agito-relay-0.10.4-x86_64-apple-darwin.tar.gz"
      sha256 "99b41cbea3a23297cf363f8a04115afb7205b9084636302e1078bd7d8b7bbf3a"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.4/agito-relay-0.10.4-aarch64-unknown-linux-musl.tar.gz"
      sha256 "155f58883bdb7b77d3a39470679342af7a274ee3b2f8e76544666882cbbcdd71"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.4/agito-relay-0.10.4-x86_64-unknown-linux-musl.tar.gz"
      sha256 "354f5e16d215bc0f33fa255e4973b417526495c3f93077261f30038f016380f7"
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
