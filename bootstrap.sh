#!/usr/bin/env bash
set -e

echo "🚀 Starting Wahyudi DevKit setup..."

# 1. Install dependencies
echo "📦 Installing system dependencies..."
sudo apt update
sudo apt install -y curl git xz-utils

# 2. Install Nix (if not installed)
if ! command -v nix >/dev/null 2>&1; then
  echo "📥 Installing Nix..."
  sh <(curl -L https://nixos.org/nix/install) --daemon
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# 3. Enable flakes
echo "⚙️ Enabling flakes..."
mkdir -p ~/.config/nix
grep -q flakes ~/.config/nix/nix.conf 2>/dev/null || \
  echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# 4. Clone repo
if [ ! -d "$HOME/devkit" ]; then
  echo "📂 Cloning devkit..."
  git clone https://github.com/wahyudibo/wahyudibo-nix-devkit.git ~/devkit
fi

cd ~/devkit

# 5. Apply config
echo "🧠 Applying Home Manager..."
nix run home-manager/master -- switch --flake .#wahyudibo

echo "✅ Done!"
echo "👉 Run: exec zsh"
