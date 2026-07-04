{ pkgs, ... }:

{
  imports = [
    ./modules/dev-tools.nix
    ./modules/git.nix
    ./modules/nvim.nix
    ./modules/packages.nix
    ./modules/shell.nix
    ./modules/sops.nix
    ./modules/ssh.nix
    ./modules/tmux.nix
  ];

  home.username = "wahyudibo";
  home.homeDirectory = "/home/wahyudibo";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
}
