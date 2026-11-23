cask "agito" do
  version "1.6,202611240046"
  sha256 "6b0f55af77c9128dc906d29c3902d296b781e31a04def5e1bf5e7e6918051c50"

  url "https://github.com/getagito/homebrew-agito/releases/download/agito-mac-v#{version.csv.first}-#{version.csv.second}/Agito-#{version.csv.first}-#{version.csv.second}.zip"
  name "Agito"
  desc "SSH terminal for AI coding agents on herdr and tmux"
  homepage "https://getagito.dev"

  depends_on macos: :sequoia

  app "Agito.app"

  zap trash: [
    "~/Library/Caches/dev.agito.app",
    "~/Library/HTTPStorages/dev.agito.app",
    "~/Library/Preferences/dev.agito.app.plist",
    "~/Library/Saved Application State/dev.agito.app.savedState",
  ]
end
