{ config, pkgs, ... }:

{
  # ── SSH
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        forwardAgent = true;
        serverAliveInterval = 30;
        serverAliveCountMax = 3;
      };

      "github-devopslingble" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_devopslingble";
        identitiesOnly = true;
      };
    };

    extraConfig = ''
      Include ${config.sops.secrets.ssh_config_extra.path}
    '';
  };
}
