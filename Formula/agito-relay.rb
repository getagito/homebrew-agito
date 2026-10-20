class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.10.12"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.12/agito-relay-0.10.12-aarch64-apple-darwin.tar.gz"
      sha256 "b6bf63d94292703b472cc27a68070162cbfec0719617a5dc9c0147f869fbc329"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.12/agito-relay-0.10.12-x86_64-apple-darwin.tar.gz"
      sha256 "16159c0b3e5cbc4f0a5d58c62a50e3eb54a3cd515bfda92b43cf21f07dae7dc5"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.12/agito-relay-0.10.12-aarch64-unknown-linux-musl.tar.gz"
      sha256 "bddc31204644a385d82e93d1c06b90b35cb351bc5986e47a81a1ca06713e7496"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.12/agito-relay-0.10.12-x86_64-unknown-linux-musl.tar.gz"
      sha256 "bc69078dcb18b565ca6d4df33dae46295efc3d322a2ef0691bc6baffb611b720"
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
