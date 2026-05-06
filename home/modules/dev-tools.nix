{ config, pkgs, ... }:

{
  # -- Mise
  xdg.configFile."mise/config.toml".source = ./../../dotfiles/mise.toml;

  # ── FZF
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;

    tmux.enableShellIntegration = true;
  };

  home.file.".local/bin/fzf-preview.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      if [ -d "$1" ]; then
        eza --tree --color=always "$1"
      else
        bat --style=numbers --color=always "$1"
      fi
    '';
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
  };

  xdg.configFile."atuin/config.toml" = {
    source = ./../../dotfiles/atuin.toml;
    force = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
