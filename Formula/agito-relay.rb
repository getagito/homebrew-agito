class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.10.8"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.8/agito-relay-0.10.8-aarch64-apple-darwin.tar.gz"
      sha256 "c2ea89786512b8b48bb11afe11ed2566920f12abb776478b97e79b4421f0e029"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.8/agito-relay-0.10.8-x86_64-apple-darwin.tar.gz"
      sha256 "f81b6b4bb3845347c3a8417407f66ce11773a208fc915a6cbd141ab2356bee7b"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.8/agito-relay-0.10.8-aarch64-unknown-linux-musl.tar.gz"
      sha256 "36513cc342bdea1fc762463d67b2d95c9ce8928c6c3c05e797fd57790056967e"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.8/agito-relay-0.10.8-x86_64-unknown-linux-musl.tar.gz"
      sha256 "c3b64b720d42dddeac0de974126c5f50c612f3e8bfa086afb7a7f42ec8d601bb"
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
