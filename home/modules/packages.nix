{ config, pkgs, ... }:

{
  # ── Dev Packages
  home.packages = with pkgs; [
    # Core
    curl wget zip

    # CLI Tools
    ripgrep fd bat eza jq

    # Infra
    sshs kubectl kubie k9s vcluster terraform

    # Editors & terminal
    zsh-fzf-tab zsh-completions tmux-sessionizer just

    # Container tools
    docker docker-compose

    # Development tools
    mise pre-commit

    # Encryption
    sops age

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
}
