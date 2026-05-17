{ config, pkgs, ... }:

{
  # ── TMUX
  programs.tmux = {
    enable = true;

    # Source the symlinked user config so edits take effect without a rebuild
    extraConfig = "source-file ${config.xdg.configHome}/tmux/tmux.user.conf";

    # Nix-managed plugins (no TPM)
    plugins = with pkgs.tmuxPlugins; [
      resurrect
      continuum
      yank
    ];
  };

  xdg.configFile."tmux/tmux.user.conf".source = ./../../dotfiles/tmux/tmux.conf;

  # ── TMS - TMUX sessionizer
  xdg.configFile."tms/config.toml".source = ./../../dotfiles/tms.toml;
}
