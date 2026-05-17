# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
just apply      # build and activate home-manager config (runs exec zsh -l after)
just update     # update all flake inputs (nixpkgs, home-manager, sops-nix)
just rebuild    # update + apply in one shot
just clean      # nix garbage collection
just doctor     # nix diagnostics
```

Changes to dotfiles that are symlinked (starship.toml, tmux/tmux.conf, atuin.toml, tms.toml) take effect immediately without a rebuild. Changes to any `.nix` file require `just apply`.

## Architecture

This is a **Nix Flakes + Home Manager** configuration targeting a single user (`wahyudibo`) on WSL2 (x86_64-linux). The flake pins nixpkgs to `nixos-25.11` and home-manager to `release-25.11`.

### Entry points

- `flake.nix` — defines the single `homeConfigurations.wahyudibo` output; allowUnfree is scoped only to `terraform`
- `home/home.nix` — imports all modules, sets SOPS config, declares which secrets exist

### Module layout (`home/modules/`)

Each file owns one concern and is imported by `home.nix`:

| Module | Owns |
|---|---|
| `shell.nix` | zsh options, initContent, starship, fzf-tab, ZLE fixes |
| `dev-tools.nix` | fzf, zoxide, atuin, direnv (all via `programs.*`) |
| `packages.nix` | raw `home.packages` — only tools with no `programs.*` module |
| `tmux.nix` | tmux + plugins (TPM-free, nix-managed), tms config |
| `git.nix` | git identity and settings |
| `ssh.nix` | SSH client config; injects the sops-decrypted `ssh_config_extra` |
| `nvim.nix` | neovim config |

**Rule**: if a tool has a home-manager `programs.<name>` module, use it — don't also list it in `packages.nix`. The `programs.*` module installs the binary AND handles shell integration.

### Dotfiles (`dotfiles/`)

Config files that are symlinked into `~/.config/` via `xdg.configFile` or `home.file`. Edited directly; no rebuild needed.

- `starship.toml` — use Nerd Font PUA symbols (e.g. ``), not wide emoji; `add_newline = false` (blank line is printed via `precmd_functions` in shell.nix instead, to keep ZLE height calculation correct)
- `tmux/tmux.conf` — prefix is `Ctrl+A`; `focus-events on` and `escape-time 0`
- `atuin.toml` — `[tmux] enabled = false` (tmux popup mode bypasses ZLE, use inline instead)

### Secrets (`secrets/`)

Managed by **sops-nix** with age encryption derived from `~/.ssh/id_ed25519`. The encrypted file is `secrets/vault.yaml`. To edit:

```bash
sops secrets/vault.yaml
```

To add a new secret, declare it in `home/home.nix` under `sops.secrets` then reference `config.sops.secrets.<name>.path` in the relevant module.

### ZLE / shell stability notes

These are load-order sensitive — the generated `~/.zshrc` has this sequence: fzf init → `initContent` → starship → direnv → atuin → syntax-highlighting. Anything that must run after atuin (e.g. overriding atuin's widget bindings) cannot go in `initContent` and needs a `precmd_functions` or deferred approach.
