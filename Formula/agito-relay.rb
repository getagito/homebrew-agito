class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.10.32"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.32/agito-relay-0.10.32-aarch64-apple-darwin.tar.gz"
      sha256 "f9e75f408daf75c47a4364b80639a6de899b9a269c210f8b96d2820f5fe9b928"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.32/agito-relay-0.10.32-x86_64-apple-darwin.tar.gz"
      sha256 "c5b2e675437d4b294c5a96cbcd169773394ea809ba539e5fa75651f95ebcc3c0"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.32/agito-relay-0.10.32-aarch64-unknown-linux-musl.tar.gz"
      sha256 "de0ec65c372ef6fb6100c1534fb557b62a5cf0811d6862fc6e0c0c1c030d488f"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.32/agito-relay-0.10.32-x86_64-unknown-linux-musl.tar.gz"
      sha256 "319c287675108bfb342b819a4556aa2842b57ec4e970b080b42c24dfa17c97b1"
    end
  end

  def install
    bin.install "agito-relay"
    # macOS 包里有 agito-simbridge 就一起装进 bin。Intel 包没编出来时文件不存在，跳过。
    if OS.mac?
      if (buildpath/"agito-simbridge").exist?
        bin.install "agito-simbridge"
      elsif Hardware::CPU.arm?
        odie "arm64 package is missing agito-simbridge"
      end
    end
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
    if OS.mac? && (bin/"agito-simbridge").exist?
      lines = shell_output("#{bin}/agito-simbridge --version").lines.map(&:strip)
      assert_match(/\Aagito-simbridge \d+\.\d+\.\d+\z/, lines.fetch(0))
      assert_match(/\Aprotocol \d+\z/, lines.fetch(1))
    end
  end
end
