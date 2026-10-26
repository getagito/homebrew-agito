cask "agito" do
  version "1.0,202610260937"
  sha256 "29f1065c7619368faf6832e327d9f1c154e579cfdde5e63fca61caa3cce8de85"

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
