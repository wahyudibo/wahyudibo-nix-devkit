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

## Architecture

This is a **Nix Flakes + Home Manager** configuration targeting a single user (`wahyudibo`) on WSL2 (x86_64-linux). The flake pins nixpkgs to `nixos-25.11` and home-manager to `release-25.11`. `home/home.nix` is the root import that pulls in all modules and declares SOPS secrets.

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

**Rule**: if a tool has a home-manager `programs.<name>` module, use it — don't also list it in `packages.nix`. The `programs.*` module installs the binary AND handles shell integration.

### What requires a rebuild vs. takes effect immediately

`xdg.configFile` entries use `source =` which creates a symlink — edits to the source file are live. `home/modules/*.nix` changes require a rebuild.

| File | Mechanism | Rebuild needed? |
|---|---|---|
| `dotfiles/starship.toml` | `xdg.configFile` symlink | No |
| `dotfiles/atuin.toml` | `xdg.configFile` symlink | No |
| `dotfiles/tms.toml` | `xdg.configFile` symlink | No |
| `dotfiles/nvim/` (Lua files) | `mkOutOfStoreSymlink` → live dir | No — changes are immediate |
| `dotfiles/tmux/tmux.conf` | `xdg.configFile` symlink | No — reload with `prefix+r` (`Ctrl+A r`) |
| Any `home/modules/*.nix` | nix evaluation | **Yes** |
| `nvim.nix` extraPackages (LSPs) | nix evaluation | **Yes** |
| `tmux.nix` plugins / extraConfig | nix evaluation | **Yes** |

### Neovim

Lua config lives in `dotfiles/nvim/lua/` and is split across `core/` (options, keymaps, plugins bootstrap) and `plugins/` (one file per plugin). The entry point is `dotfiles/nvim/init.lua` which loads `core.options`, `core.keymaps`, and `core.plugins` (lazy.nvim). `~/.config/nvim` is a `mkOutOfStoreSymlink` pointing directly to `dotfiles/nvim/` — new Lua files are immediately visible without `git add` or `just apply`.

**LSPs and formatters are installed by nix** in `nvim.nix` `extraPackages` (gopls, terraform-ls, yaml-language-server, lua-language-server, stylua, gofumpt, etc.) — there is no Mason. Adding a new LSP or formatter means adding it to `extraPackages` and running `just apply`. LSPs are enabled via `vim.lsp.enable({...})` in `plugins/lsp.lua` (Neovim 0.11+ API — do not use the old `require('lspconfig').server.setup()` pattern).

Plugins are managed by lazy.nvim (bootstrapped in `core/plugins.lua`). Plugin options that must be read at plugin load time (e.g. `@continuum-restore`) must be set **before** their `run-shell` fires — use the plugin's `extraConfig` in `tmux.nix`, not the user conf.

### Tmux

Plugins are declared in `tmux.nix` (no TPM). The generated `~/.config/tmux/tmux.conf` is nix-managed and read-only; user settings live in `dotfiles/tmux/tmux.conf` which is symlinked as `~/.config/tmux/tmux.user.conf` and sourced at the end of the generated config.

**Critical constraint — plugin option ordering:** Some tmux plugin options must be set **before** that plugin's `run-shell` fires (they are read at load time). These must live in the plugin's `extraConfig` block inside `tmux.nix`, not in `tmux.conf`. Options read at save/restore time (e.g. `@resurrect-strategy-nvim`) are safe to put in `tmux.conf`.

| Option | Where it must live | Why |
|---|---|---|
| `@continuum-restore 'on'` | `tmux.nix` plugin extraConfig | Read by continuum at startup |
| `@continuum-save-interval` | `tmux.nix` plugin extraConfig | Read by continuum at startup |
| `@yank_selection 'clipboard'` | `tmux.nix` plugin extraConfig | Read by yank when setting up bindings |
| `status-right` | `tmux.nix` resurrect extraConfig | continuum prepends `#(continuum_save.sh)` to it at load time; any `set -g status-right` in `tmux.conf` (sourced last) would overwrite the injected hook and break auto-save |
| `@resurrect-strategy-nvim` | `tmux.conf` is fine | Read at save/restore time |
| `@resurrect-capture-pane-contents` | `tmux.conf` is fine | Read at save/restore time |

Plugin load order matters: `resurrect` must load before `continuum` (dependency). Current order: `resurrect → continuum → yank`.

Reload user config without rebuilding: `prefix+r` (`Ctrl+A r`) — sources `tmux.user.conf` only.

### Dotfiles (`dotfiles/`)

- `starship.toml` — use Nerd Font PUA symbols (e.g. ``), not wide emoji; `add_newline = false` (blank line is printed via `precmd_functions` in shell.nix instead, to keep ZLE height calculation correct for multi-line paste)
- `tmux/tmux.conf` — symlinked as `tmux.user.conf`; prefix is `Ctrl+A`; `focus-events on` and `escape-time 0`; plugin load-time options belong in `tmux.nix` extraConfig, not here
- `atuin.toml` — `[tmux] enabled = false` (tmux popup mode bypasses ZLE; inline mode is required)

### Secrets (`secrets/`)

Managed by **sops-nix** with age encryption derived from `~/.ssh/id_ed25519`. Edit the vault with:

```bash
sops secrets/vault.yaml
```

To add a new secret: declare it in `home/home.nix` under `sops.secrets`, then reference `config.sops.secrets.<name>.path` in the relevant module.

### WSL files (`wsl/`)

These are **not managed by home-manager** and must be placed manually:

- `wsl/.wslconfig` → `%USERPROFILE%\.wslconfig` on the **Windows host** (not inside WSL)
- `wsl/wsl.conf` → `/etc/wsl.conf` inside WSL

Changes to either file require restarting the WSL instance (`wsl --shutdown` from PowerShell) to take effect.

### Shell init load order (important)

The generated `~/.zshrc` loads in this sequence: fzf init → `initContent` → starship → direnv → atuin → syntax-highlighting. Anything that must run after atuin (e.g. overriding atuin's ZLE widget bindings) cannot go in `initContent` and needs a `precmd_functions` or deferred approach instead.
