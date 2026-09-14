class AgitoRelay < Formula
  desc "Sends coding agent status from Herdr and tmux to Agito push notifications"
  homepage "https://getagito.dev"
  version "0.1.0"

  on_macos do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.1.0/agito-relay-0.1.0-aarch64-apple-darwin.tar.gz"
      sha256 "8cee7ad11342e02c97843121a4a40a843dcc5f1f929c74d4d12324b50cf83827"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.1.0/agito-relay-0.1.0-x86_64-apple-darwin.tar.gz"
      sha256 "906162e316f34c0fb0b84b9a2b21710597bd7c003f7e531e797adbe5c4d6c66d"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.1.0/agito-relay-0.1.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "8dbf1a7bce43354d7a0233e5139ff55999693baf5b345fe01dba9b50c9cb0011"
    end
    on_intel do
      url "https://github.com/getagito/homebrew-agito/releases/download/agito-relay-v0.1.0/agito-relay-0.1.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "220a584dd497be556e8cc97a0f807ebe27737fe416fe2ba67d4578d7a93443e5"
    end
  end

  def install
    bin.install "agito-relay"
    pkgshare.install "claude-hooks.json", "merge-claude-hooks.mjs"
  end

  service do
    run [opt_bin/"agito-relay"]
    keep_alive true
    environment_variables PATH: std_service_path_env
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
