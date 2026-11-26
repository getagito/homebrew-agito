class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.10.42"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.42/agito-relay-0.10.42-aarch64-apple-darwin.tar.gz"
      sha256 "2e863321854775f182954b31218958bb4049eafb5a8a8c9ba4887ff6d75ab806"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.42/agito-relay-0.10.42-x86_64-apple-darwin.tar.gz"
      sha256 "ea09693ef2d229d65634b3fbe898f2e47576ed6c7ffff075e417f1627a56a7ae"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.42/agito-relay-0.10.42-aarch64-unknown-linux-musl.tar.gz"
      sha256 "ee22d5b2ddfb114d6d5b511cebd117407b7d715d78288205778cdf608330bad4"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.42/agito-relay-0.10.42-x86_64-unknown-linux-musl.tar.gz"
      sha256 "c075536040f296fce67aa9e7c1c84f4e5b21414365c9154cf1f63066241717d5"
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
    # 按交互进程调度：不写时 launchd 按 daemon 起（线程 PRI 20），主机满负载时 relay 请求慢约 25 倍。
    process_type :interactive
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
