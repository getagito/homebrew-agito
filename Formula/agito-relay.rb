class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.10.30"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.30/agito-relay-0.10.30-aarch64-apple-darwin.tar.gz"
      sha256 "f46ec5eebd070df893f274e00c4dca9bc85f0bcf0fc46882d6ef5278a53bc229"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.30/agito-relay-0.10.30-x86_64-apple-darwin.tar.gz"
      sha256 "e72cc7daa26e681a2282ea990c6f829af114a5e25101a4bc105178cad56d8f57"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.30/agito-relay-0.10.30-aarch64-unknown-linux-musl.tar.gz"
      sha256 "ca5cabae8e968f8da92d94975e238e41325ea9719ea9626dcdf2980c0e622915"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.30/agito-relay-0.10.30-x86_64-unknown-linux-musl.tar.gz"
      sha256 "4190a109088f0eff5293330c6dc9d87c6cd270c84cbd277b45ec7c2ff5d4e7bd"
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
