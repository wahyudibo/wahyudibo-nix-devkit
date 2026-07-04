# 🧰 Wahyudi DevKit (Nix + Home Manager)

A fully reproducible developer environment powered by **Nix Flakes + Home Manager**.

> One command → fully working dev machine 🚀

---

## ✨ Features

* ⚡ Fast setup (minutes on fresh machine)
* 🔁 Fully reproducible environment
* 🧠 Minimal + modern CLI stack
* 🐧 Optimized for WSL2 (Debian)

---

## 🧱 Stack

| Category   | Tools                           |
| ---------- | ------------------------------- |
| Shell      | zsh + starship                  |
| Navigation | fzf + zoxide                    |
| Search     | ripgrep + fd                    |
| Viewing    | bat + eza                       |
| Runtime    | mise                            |
| Infra      | docker, kubectl, terraform, k9s |
| Editor     | neovim (LSP ready)              |
| Terminal   | tmux                            |
| History    | atuin                           |

---

## 🚀 Quick Start (Recommended)

### One-liner install

```bash
bash <(curl -s https://raw.githubusercontent.com/wahyudibo/wahyudibo-nix-devkit/main/bootstrap.sh)
```

---

## 🔧 Manual Setup (Step by Step)

### 1. Install dependencies

```bash
sudo apt update
sudo apt install -y curl git xz-utils
```

---

### 2. Install Nix

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
exec $SHELL
```

---

### 3. Enable flakes

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

---

### 4. Clone repo

```bash
git clone https://github.com/wahyudibo/wahyudibo-nix-devkit.git ~/devkit
cd ~/devkit
```

---

### 5. Apply config

```bash
nix run home-manager/master -- switch --flake .#wahyudibo
```

---

### 6. Reload shell

```bash
exec zsh
```

---

## 🔑 SSH Setup (Optional)

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

---

## 🧪 Verify

```bash
fzf
nvim .
tmux
```

---

## ⚡ Dev Commands (via `just`)

```bash
just apply      # apply nix config
just clean      # garbage collect
just update     # update flake inputs
just rebuild    # full rebuild
```

---

## 📁 Structure

```
.
├── flake.nix
├── home/
│   ├── home.nix
│   └── modules/
│       ├── sops.nix
│       └── ...
├── dotfiles/
│   ├── nvim/
│   ├── starship.toml
│   ├── atuin.toml
│   └── ...
├── secrets/
│   └── vault.yaml
├── bootstrap.sh
├── justfile
└── .envrc
```

---

## 🔐 Secrets Management (`sops-nix`)

This environment uses **sops-nix** to manage sensitive data (like SSH host IPs and API tokens) securely. Secrets are encrypted with **age** and can be safely committed to GitHub.

### 1. Generate Encryption Keys
Encryption is based on your existing SSH private key. You must convert it to the `age` format once on every new machine.

Run these commands to generate the private key
```bash
# Create the directory
mkdir -p ~/.config/sops/age

# Convert your PRIVATE SSH key to age format
nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i ~/.ssh/id_ed25519" > ~/.config/sops/age/keys.txt

# Secure the permissions
chmod 600 ~/.config/sops/age/keys.txt
```

and this command to generate the public key
```bash
nix-shell -p ssh-to-age --run "ssh-to-age -i ~/.ssh/id_ed25519.pub"
```

### 2. Create or Edit the Vault
```bash
# This decrypts the file, opens it in Neovim, and re-encrypts on save
sops secrets/vault.yaml
```

### 3. Adding New Secret Types
To add a new secret to your build, register it in `home/modules/sops.nix`

```nix
sops.secrets.my_new_secret = {};
```

---

## 🧠 Philosophy

* ❌ No global installs
* ❌ No manual setup
* ✅ Everything declarative
* ✅ Everything reproducible

---

## 📄 License

MIT
