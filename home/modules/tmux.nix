{ config, pkgs, ... }:

{
  # ── TMUX
  programs.tmux = {
    enable = true;

    # Inject settings directly where the plugins are defined
    plugins = with pkgs.tmuxPlugins; [
      resurrect
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
        '';
      }
      {
        plugin = yank;
        extraConfig = ''
          set -g @yank_selection 'clipboard'
        '';
      }
    ];

    extraConfig = "source-file ${config.xdg.configHome}/tmux/tmux.user.conf";
  };

  xdg.configFile."tmux/tmux.user.conf".source = ./../../dotfiles/tmux/tmux.conf;

  # ── TMS - TMUX sessionizer
  xdg.configFile."tms/config.toml".source = ./../../dotfiles/tms.toml;
}
