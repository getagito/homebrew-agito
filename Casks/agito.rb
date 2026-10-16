cask "agito" do
  version "1.0,202610161940"
  sha256 "923316db4f9a62d1d7e5097a86910bcc20652f381ed3949d9a58dfd598b50386"

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
