{ config, pkgs, ... }:

{
  home.username = "wahyudibo";
  home.homeDirectory = "/home/wahyudibo";

  programs.home-manager.enable = true;

  # ── Shell ────────────────────────────────
  programs.zsh.enable = true;
  home.file.".zshrc".source = ./../dotfiles/.zshrc;
  home.file.".zshrc".force = true;

  # ── Starship prompt
  programs.starship.enable = true;
  xdg.configFile."starship.toml".source = ./../dotfiles/starship.toml;

  # ── TMUX
  programs.tmux.enable = true;

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
    extraConfig = ''
      " init.vim content here, e.g. source ~/.config/nvim/init.vim
    '';
  };

  home.stateVersion = "23.11";
}