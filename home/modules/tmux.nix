{ config, pkgs, ... }:

{
  # ── TMUX
  programs.tmux = {
    enable = true;

    # Inject settings directly where the plugins are defined
    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = resurrect;
        # status-right MUST be set before continuum's run-shell fires,
        # because continuum prepends #(continuum_save.sh) to status-right at
        # load time. If tmux.user.conf sets status-right after plugins load,
        # it clobbers the save-script interpolation and auto-save breaks.
        extraConfig = ''
          set -g status-right "#[fg=#89dceb]#(awk '{print \"load \" $1}' /proc/loadavg) #[fg=#6c7086]| #[fg=#fab387]#(free -h | awk '/Mem/ {print \"RAM \" $3}') #[fg=#6c7086]| #[fg=#a6adc8]%H:%M"
        '';
      }
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
