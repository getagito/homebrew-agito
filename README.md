# Agito Homebrew Tap

`agito-relay` runs on your development machine and sends coding agent status from Herdr and tmux to [Agito](https://getagito.dev) push notifications.

```bash
brew install getagito/agito/agito-relay
brew services start agito-relay
```

Then turn on notifications in the Agito app. It pairs with this machine over SSH.

- Supported platforms: macOS (Apple silicon, Intel) and Linux (arm64, x86_64).
- On Linux, run `loginctl enable-linger "$USER"` so the relay keeps running after you log out.
- The relay uploads nothing until at least one device has subscribed to this machine. It never uploads terminal output, prompts or code.
