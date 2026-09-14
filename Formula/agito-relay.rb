class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.1.1"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.1.1/agito-relay-0.1.1-aarch64-apple-darwin.tar.gz"
      sha256 "f206a4066c98b5f0ca86c3124c8cfe9ede3a12342a9ed048e8fded7bdba257ee"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.1.1/agito-relay-0.1.1-x86_64-apple-darwin.tar.gz"
      sha256 "310abb2c09c316cb03a0c3b6a781476580b1d620d9fefd65324fe00b4311bc9e"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.1.1/agito-relay-0.1.1-aarch64-unknown-linux-musl.tar.gz"
      sha256 "49e0dfd8a10f02ccdd780da9efaebf880d2f0999df07e62ed76ba1fe1a76688b"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.1.1/agito-relay-0.1.1-x86_64-unknown-linux-musl.tar.gz"
      sha256 "801c291b530d59cbed94076614cbccae460214621b9c8e45dfd371a121391f61"
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
