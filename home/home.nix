{ config, pkgs, ... }:

{
  home.username = "wahyudibo";
  home.homeDirectory = "/home/wahyudibo";

  programs.home-manager.enable = true;

  # ── Shell ────────────────────────────────
  programs.zsh = {
    enable = true;

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 10000;
      path = "${config.home.homeDirectory}/.zsh_history";
      share = true;
    };

    shellAliases = {
      ls = "eza --icons --group-directories-first";
      ll = "eza -lh --git";
      tree = "eza --tree";
      cat = "bat";
      grep = "rg";
      find = "fd";
    };

    initContent = ''
      # ── mise
      export PATH="$HOME/.mise/bin:$PATH"
      if command -v mise >/dev/null 2>&1; then
        eval "$(mise hook zsh)"
      fi

      # ── zoxide
      eval "$(zoxide init zsh)"

      # ── fzf
      export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"

      # ── starship
      eval "$(starship init zsh)"

      # ── keybindings
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down

      # ── tmux autostart
      if command -v tmux >/dev/null 2>&1 && [ -z "$TMUX" ]; then
        exec tmux
      fi
    '';
  };

  # ── Starship prompt
  programs.starship.enable = true;
  xdg.configFile."starship.toml".source = ./../dotfiles/starship.toml;

  # ── TMUX
  programs.tmux = {
    enable = true;
    extraConfig = ''
      set -g mouse on
      set -g prefix C-a
      unbind C-b
      bind C-a send-prefix

      bind | split-window -h
      bind - split-window -v
    '';
  };

  # ── Git
  programs.git = {
    enable = true;
    settings = {
      user.name = "wahyudibo";
      user.email = "wahyudi.ibo.wibowo@gmail.com";
    };
    signing.format = "openpgp";
  };

  # ── SSH
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

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
    fzf ripgrep fd bat eza zoxide

    # Infra
    kubectl kubectx k9s terraform

    # Editors & terminal
    starship tmux

    # Container tools
    docker docker-compose

    # mise for managing Node/Python/Ruby/Go
    mise
  ];

  # ── Neovim minimal setup
  programs.neovim = {
    enable = true;
    vimAlias = true;
    defaultEditor = true;

    # Use Lua config
    initLua = ''
      require("core.options")
      require("core.keymaps")
      require("core.plugins")
    '';

    # Essential runtime deps
    extraPackages = with pkgs; [
      # LSP
      gopls
      terraform-ls
      nodePackages.yaml-language-server
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

  home.stateVersion = "23.11";
}