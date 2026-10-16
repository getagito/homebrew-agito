cask "agito" do
  version "1.0,202610161509"
  sha256 "9e20a7c9412a2e8c34cdf202fe0b707f4922e58df72e9728b15eacf078b18647"

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
