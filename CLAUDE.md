# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture

This is a **Nix Flakes + Home Manager** configuration targeting a single user (`wahyudibo`) on WSL2 (x86_64-linux). `home/home.nix` is the root import that pulls in all modules and declares SOPS secrets.

### Module layout (`home/modules/`)

Each file owns one concern and is imported by `home.nix`:

| Module | Owns |
|---|---|
| `shell.nix` | zsh options, initContent, starship, fzf-tab, ZLE fixes |
| `dev-tools.nix` | fzf, zoxide, atuin, direnv (all via `programs.*`) |
| `packages.nix` | raw `home.packages` — only tools with no `programs.*` module |
| `tmux.nix` | tmux + nix-managed plugins (no TPM), tms config |
| `git.nix` | git identity and settings |
| `ssh.nix` | SSH client config; injects the sops-decrypted `ssh_config_extra` |
| `nvim.nix` | neovim binary, LSPs, formatters, and Lua config symlink |
| `sops.nix` | sops-nix import + secret declarations (`sops.defaultSopsFile`, `sops.secrets`) |

**Rule**: if a tool has a home-manager `programs.<name>` module, use it — don't also list it in `packages.nix`. The `programs.*` module installs the binary AND handles shell integration.

### What requires a rebuild vs. takes effect immediately

`xdg.configFile` entries with `source =` copy the file into the **nix store** and symlink there — edits to the dotfiles source are **not** live; a rebuild is needed. Only `mkOutOfStoreSymlink` creates a direct symlink to the source file. `home/modules/*.nix` changes always require a rebuild.

| File | Mechanism | Rebuild needed? |
|---|---|---|
| `dotfiles/starship.toml` | `xdg.configFile` → nix store copy | **Yes** |
| `dotfiles/atuin.toml` | `xdg.configFile` → nix store copy | **Yes** |
| `dotfiles/tms.toml` | `xdg.configFile` → nix store copy | **Yes** |
| `dotfiles/nvim/` (Lua files) | `mkOutOfStoreSymlink` → live dir | No — changes are immediate |
| `dotfiles/tmux/tmux.conf` | `xdg.configFile` → nix store copy | **Yes** — after `just apply`, reload with `prefix+r` (`Ctrl+A r`) |
| Any `home/modules/*.nix` | nix evaluation | **Yes** |
| `nvim.nix` extraPackages (LSPs) | nix evaluation | **Yes** |
| `tmux.nix` plugins / extraConfig | nix evaluation | **Yes** |

Neovim-specific and Tmux-specific gotchas now live in `dotfiles/nvim/CLAUDE.md` and `dotfiles/tmux/CLAUDE.md` (loaded only when working in those dirs).

### Dotfiles (`dotfiles/`)

- `starship.toml` — use Nerd Font PUA symbols (e.g. ``), not wide emoji; `add_newline = false` (blank line is printed via `precmd_functions` in shell.nix instead, to keep ZLE height calculation correct for multi-line paste)
- `tmux/tmux.conf` — symlinked as `tmux.user.conf`; prefix is `Ctrl+A`; `focus-events on` and `escape-time 0`; plugin load-time options and `status-right` belong in `tmux.nix` extraConfig, not here
- `atuin.toml` — `[tmux] enabled = false` (tmux popup mode bypasses ZLE; inline mode is required)

### Secrets (`secrets/`)

Managed by **sops-nix** with age encryption derived from `~/.ssh/id_ed25519`. Edit the vault with:

```bash
sops secrets/vault.yaml
```

To add a new secret: declare it in `home/modules/sops.nix` under `sops.secrets`, then reference `config.sops.secrets.<name>.path` in the relevant module.

### WSL files (`wsl/`)

These are **not managed by home-manager** and must be placed manually:

- `wsl/.wslconfig` → `%USERPROFILE%\.wslconfig` on the **Windows host** (not inside WSL)
- `wsl/wsl.conf` → `/etc/wsl.conf` inside WSL

Changes to either file require restarting the WSL instance (`wsl --shutdown` from PowerShell) to take effect.

### Shell init load order (important)

The generated `~/.zshrc` loads in this sequence: fzf init → `initContent` → starship → direnv → atuin → syntax-highlighting. Anything that must run after atuin (e.g. overriding atuin's ZLE widget bindings) cannot go in `initContent` and needs a `precmd_functions` or deferred approach instead.
