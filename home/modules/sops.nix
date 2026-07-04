{ config, inputs, ... }:

{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    defaultSopsFile = ./../../secrets/vault.yaml;
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    secrets = {
      ssh_config_extra = {};
      github_token = {};
      context7_api_key = {};
    };
  };
}
