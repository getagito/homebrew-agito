class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.10.5"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.5/agito-relay-0.10.5-aarch64-apple-darwin.tar.gz"
      sha256 "acd7e1988380200e2b7b978f216d734784ef6d7bbfecda542d161ccf0a7057f1"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.5/agito-relay-0.10.5-x86_64-apple-darwin.tar.gz"
      sha256 "944da0f44248bbe0a4b04cf78653d5e352b5247b856f7ab462911b96d09b5cab"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.5/agito-relay-0.10.5-aarch64-unknown-linux-musl.tar.gz"
      sha256 "d4e6e595bf79d2cf50182d5e168171330fe0cdf0415ab5098d0ee3936ea765eb"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.10.5/agito-relay-0.10.5-x86_64-unknown-linux-musl.tar.gz"
      sha256 "4832885cbabb20500a5834bf97db6b5309bb437fadf7d0a9ac692f28c04bba97"
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
