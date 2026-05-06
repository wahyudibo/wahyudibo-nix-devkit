{ config, pkgs, ... }:

{
  # ── TMUX
  programs.tmux = {
    enable = true;

    # Use external config file
    extraConfig = builtins.readFile ./../../dotfiles/tmux/tmux.conf;

    # Nix-managed plugins (no TPM)
    plugins = with pkgs.tmuxPlugins; [
      resurrect
      continuum
      yank
    ];
  };

  # ── TMS - TMUX sessionizer
  xdg.configFile."tms/config.toml".source = ./../../dotfiles/tms.toml;
}
