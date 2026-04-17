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
│   └── home.nix
├── config/
│   ├── nvim/
│   ├── starship.toml
│   ├── atuin.toml
│   └── ...
├── bootstrap.sh
├── justfile
└── .envrc
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
