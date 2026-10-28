class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.10.19"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.19/agito-relay-0.10.19-aarch64-apple-darwin.tar.gz"
      sha256 "caf3ddc84a691cc0bf9ca75cd576bd1d962414a6390131599ea87c76d7ed4365"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.19/agito-relay-0.10.19-x86_64-apple-darwin.tar.gz"
      sha256 "f7d1ba803fc6888ce0d77bd9e6703c05ee30afbc1f8a634f9efb1148d113376e"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.19/agito-relay-0.10.19-aarch64-unknown-linux-musl.tar.gz"
      sha256 "44e5a91dd4ec1af54a51e5b123895f10775a349dc3e1ac6974a99174f3d73f8d"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.19/agito-relay-0.10.19-x86_64-unknown-linux-musl.tar.gz"
      sha256 "ac4e358e3b1d06cac5af82fa35f8975ca4e83e8cbfa55b38dee56cdacb7051f1"
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
