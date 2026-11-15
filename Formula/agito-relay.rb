class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.10.27"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.27/agito-relay-0.10.27-aarch64-apple-darwin.tar.gz"
      sha256 "fd5dfb9d993c13232ac51eb4ab85ebe7f0e1fb5f74dd284c0f44874244306189"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.27/agito-relay-0.10.27-x86_64-apple-darwin.tar.gz"
      sha256 "c255c8d3d6a58dc1fd3aaa35bf50f16efa79c93e5e58288172ab8c918b45459d"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.27/agito-relay-0.10.27-aarch64-unknown-linux-musl.tar.gz"
      sha256 "b3cbe1d29fb3f42b77555ed71767b0cf8aef5df49ec65afd1c2116b5be56d88a"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.27/agito-relay-0.10.27-x86_64-unknown-linux-musl.tar.gz"
      sha256 "d46f213a8f80af24d8d18d93a12ca653d1083111772cb4a9b88c060fe3b45289"
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
