{ config, pkgs, ... }:

{
  home.username = "wahyudibo";
  home.homeDirectory = "/home/wahyudibo";

  programs.home-manager.enable = true;

  # ── Shell ────────────────────────────────
  programs.zsh = {
    enable = true;

    enableCompletion = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 10000;
      save = 10000;
      path = "${config.home.homeDirectory}/.zsh_history";
    };

    shellAliases = {
      ls = "eza --icons --group-directories-first";
      ll = "eza -lh --git";
      tree = "eza --tree";
      cat = "bat";
      grep = "rg";
      find = "fd";
      c = "code .";
      e = "explorer.exe .";
    };

    initExtra = ''
      export PATH="$HOME/.local/bin:$PATH"

      # ── mise
      export PATH="$HOME/.mise/bin:$PATH"
      if command -v mise >/dev/null 2>&1; then
        eval "$(mise activate zsh)"
      fi

      # ── zoxide
      eval "$(zoxide init zsh)"

      # ── tmux autostart
      if command -v tmux >/dev/null 2>&1 && [ -z "$TMUX" ] && [ -n "$PS1" ]; then
        tmux attach-session -t main || tmux new-session -s main
      fi

      # ── tmux-sessionizer (tms)
      export TMS_CONFIG_FILE="$HOME/.config/tms/config.toml"

      # ── fzf
      export FZF_DEFAULT_OPTS="--height=80% --layout=reverse --border --preview='fzf-preview.sh {}'"
      export FZF_TMUX_OPTS="-p 80%,60%"

      # ── fzf-tab
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

      # Optional: Disable default preview for fzf-tab to keep it light
      zstyle ':fzf-tab:*' fzf-command fzf

      zstyle ':fzf-tab:*' switch-group '<' '>'
      zstyle ':fzf-tab:*' fzf-flags --preview-window=hidden:wrap

      # ── starship
      eval "$(starship init zsh)"
    '';
  };

  # ── Starship prompt
  programs.starship.enable = true;
  xdg.configFile."starship.toml".source = ./../dotfiles/starship.toml;

  # ── TMUX
  programs.tmux = {
    enable = true;

    # Use external config file
    extraConfig = builtins.readFile ./../dotfiles/tmux/tmux.conf;

    # Nix-managed plugins (no TPM)
    plugins = with pkgs.tmuxPlugins; [
      resurrect
      continuum
      yank
    ];
  };

  # ── TMS - TMUX sessionizer
  xdg.configFile."tms/config.toml".source = ./../dotfiles/tms.toml;

  # -- Mise
  xdg.configFile."mise/config.toml".source = ./../dotfiles/mise.toml;

  # ── Git
  programs.git = {
    enable = true;
    userName = "wahyudibo";
    userEmail = "wahyudi.ibo.wibowo@gmail.com";

    extraConfig = {
      gpg.format = "openpgp";
    };
  };

  # ── SSH
  programs.ssh = {
    enable = true;

    matchBlocks = {
      "*" = {
        forwardAgent = true;
      };
    };
  };

  # ── Dev Packages
  home.packages = with pkgs; [
    # Core
    git curl wget

    # CLI Tools
    fzf ripgrep fd bat eza zoxide atuin direnv

    # Infra
    kubectl kubectx k9s terraform

    # Editors & terminal
    zsh-fzf-tab zsh-completions starship tmux tmux-sessionizer just

    # Container tools
    docker docker-compose

    # tools for development
    mise pre-commit

    # go
    go
    gopls
    golangci-lint
    gotools

    # js
    biome

    # rust
    rust-analyzer
    clippy
    rustfmt
  ];

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

  # ── Neovim minimal setup
  programs.neovim = {
    enable = true;
    vimAlias = true;
    defaultEditor = true;

    # Use Lua config
    extraLuaConfig = ''
      require("core.options")
      require("core.keymaps")
      require("core.plugins")
    '';

    withPython3 = false;
    withRuby = false;

    # Essential runtime deps
    extraPackages = with pkgs; [
      # LSP
      gopls
      terraform-ls
      yaml-language-server
      lua-language-server

      # Treesitter deps
      tree-sitter

      # Telescope deps
      ripgrep
      fd

      # Formatting
      stylua
      gofumpt

      # Go specifics
      gotools
      golangci-lint
    ];
  };
  xdg.configFile."nvim".source = ./../dotfiles/nvim;

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
  };
  xdg.configFile."atuin/config.toml" = {
    source = ./../dotfiles/atuin.toml;
    force = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.stateVersion = "23.11";
}
