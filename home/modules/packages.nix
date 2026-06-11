{ config, pkgs, ... }:

{
  # ── Dev Packages
  home.packages = with pkgs; [
    # Unix tools
    unixtools.netstat
    unixtools.route
    unixtools.col
    unixtools.column
    unixtools.xxd

    # Core
    curl wget zip

    # CLI Tools
    ripgrep fd bat eza jq

    # Editors & terminal
    zsh-fzf-tab zsh-completions tmux-sessionizer just

    # Container tools
    docker_29 docker-compose

    # Development tools
    mise

    # Encryption
    sops age gnupg pinentry-curses

    # go
    go
    gopls
    golangci-lint
    gotools

    # rust
    rust-analyzer
    clippy
    rustfmt
  ];
}
