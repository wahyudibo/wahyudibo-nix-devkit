{ config, pkgs, inputs, ... }:

{
  imports = [
    # ── SOPS encryption for secrets management
    inputs.sops-nix.homeManagerModules.sops
    ./modules/dev-tools.nix
    ./modules/git.nix
    ./modules/nvim.nix
    ./modules/packages.nix
    ./modules/shell.nix
    ./modules/ssh.nix
    ./modules/tmux.nix
  ];

  home.username = "wahyudibo";
  home.homeDirectory = "/home/wahyudibo";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  # ── SOPS Configuration ──────────────────
  sops = {
    defaultSopsFile = ./../secrets/vault.yaml;
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    secrets = {
      ssh_config_extra = {};
      github_token = {};
      context7_api_key = {};
    };
  };
}
