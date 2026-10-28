class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.10.18"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.18/agito-relay-0.10.18-aarch64-apple-darwin.tar.gz"
      sha256 "5cc3f87e1c9eb46c22d832b937086dec38e4b370df08e3ad06dad36ce2086fd6"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.18/agito-relay-0.10.18-x86_64-apple-darwin.tar.gz"
      sha256 "639208fa390a5372e28438ed0985c35eb0a0325fb0b4db0d3f6a33091753660d"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.18/agito-relay-0.10.18-aarch64-unknown-linux-musl.tar.gz"
      sha256 "b0e104e00ad90e9176223528b67f0a8cb8898d1f8ff07e12bb0433c6a406a548"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.18/agito-relay-0.10.18-x86_64-unknown-linux-musl.tar.gz"
      sha256 "b1c5d7d233c9930d3fb289d33e932d1ddf418644f20cb8e86c63bf94a521165d"
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

      Then add this machine in the Agito app (prints a QR code to scan with your phone):
        agito-relay host setup

      Finally turn on notifications in the Agito app. It connects to this machine over SSH.

      Herdr sessions work without extra setup. For Claude Code running directly in tmux,
      merge the hooks into your Claude settings (prints the merged file, does not overwrite):
        node #{pkgshare}/merge-claude-hooks.mjs ~/.claude/settings.json
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/agito-relay --version")
  end
end
