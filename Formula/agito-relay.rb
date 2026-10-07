class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.9.3"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.9.3/agito-relay-0.9.3-aarch64-apple-darwin.tar.gz"
      sha256 "815343cc24e310b22bf283e49cd1c46b9f907825c0c689cd09593a70f7876ea2"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.9.3/agito-relay-0.9.3-x86_64-apple-darwin.tar.gz"
      sha256 "5a8ad250de5e63af6ab1d317ba5936c824895baffe781a42181ff4eed31b8e40"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.9.3/agito-relay-0.9.3-aarch64-unknown-linux-musl.tar.gz"
      sha256 "e0f8326766bdeb0dd0cf1046220ccedf9d6cd911bf796e1727a3b86e158f93d3"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.9.3/agito-relay-0.9.3-x86_64-unknown-linux-musl.tar.gz"
      sha256 "e7c52df49af5d75536776b1f94482faccd55c5d32844068951476d1b57e5db70"
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
