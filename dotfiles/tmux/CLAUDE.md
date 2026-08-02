Plugins are declared in `tmux.nix` (no TPM). The generated `~/.config/tmux/tmux.conf` is nix-managed and read-only; user settings live in `dotfiles/tmux/tmux.conf` which is symlinked as `~/.config/tmux/tmux.user.conf` and sourced at the end of the generated config.

Active plugins: `yank` only. Resurrect and continuum were removed — they conflict with WSL2 sleep/wake cycles and caused windows to restore at index 0 despite `base-index 1`.

`base-index 1` and `pane-base-index 1` are set via `programs.tmux.baseIndex = 1` in `tmux.nix` (top of generated config) so they can never be overridden by restore order. `status-right` is set in `programs.tmux.extraConfig` (before `source-file tmux.user.conf`).

| Option | Where it must live | Why |
|---|---|---|
| `@yank_selection 'clipboard'` | `tmux.nix` plugin extraConfig | Read by yank when setting up bindings |
| `status-right` | `tmux.nix` extraConfig | Must not be overridden by user.conf |

Reload user config without rebuilding: `prefix+r` (`Ctrl+A r`) — sources `tmux.user.conf` only.
