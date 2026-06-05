{ config, pkgs, ... }:

{
  # ── TMUX
  programs.tmux = {
    enable = true;
    baseIndex = 1;

    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = yank;
        extraConfig = ''
          set -g @yank_selection 'clipboard'
        '';
      }
    ];

    extraConfig = ''
      set -g status-right "#[fg=#89dceb]#(awk '{print \"load \" $1}' /proc/loadavg) #[fg=#6c7086]| #[fg=#fab387]#(free -h | awk '/Mem/ {print \"RAM \" $3}') #[fg=#6c7086]| #[fg=#a6adc8]%H:%M"
      source-file ${config.xdg.configHome}/tmux/tmux.user.conf
    '';
  };

  xdg.configFile."tmux/tmux.user.conf".source = ./../../dotfiles/tmux/tmux.conf;

  # ── TMS - TMUX sessionizer
  xdg.configFile."tms/config.toml".source = ./../../dotfiles/tms.toml;
}
