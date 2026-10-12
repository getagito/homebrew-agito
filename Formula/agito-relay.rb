class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.10.0"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.0/agito-relay-0.10.0-aarch64-apple-darwin.tar.gz"
      sha256 "62a449e8b96ba41011595bdf49c990fa93aee307e255e07e5f8db604106af7ba"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.0/agito-relay-0.10.0-x86_64-apple-darwin.tar.gz"
      sha256 "3bbb2f00c57f956a6427577db3a99a321bb36849ca810e55606cd185ee46e0a1"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.0/agito-relay-0.10.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "6397a78140e623f694981187f497e3eae8eb1319e0471fdc3db5a6a14d8ff8c5"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.0/agito-relay-0.10.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "79626a352aa5f1c7b28d908af340b9f25b35928255fcca9af5b51c0c4f6d7bdc"
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
