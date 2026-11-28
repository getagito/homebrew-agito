cask "agito" do
  version "1.6,202611280911"
  sha256 "d8f74c2b0bde6e4608e2821ec9bc776a11ff3e6e14b9e30393c874d328eaff61"

  url "https://github.com/getagito/homebrew-agito/releases/download/agito-mac-v#{version.csv.first}-#{version.csv.second}/Agito-#{version.csv.first}-#{version.csv.second}.dmg"
  name "Agito"
  desc "SSH terminal for AI coding agents on herdr and tmux"
  homepage "https://getagito.dev"

  auto_updates true
  depends_on macos: :sequoia

  app "Agito.app"

  zap trash: [
    "~/Library/Caches/dev.agito.app",
    "~/Library/HTTPStorages/dev.agito.app",
    "~/Library/Preferences/dev.agito.app.plist",
    "~/Library/Saved Application State/dev.agito.app.savedState",
  ]
end
