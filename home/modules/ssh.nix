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
    };

    extraConfig = ''
      Include ${config.sops.secrets.ssh_config_extra.path}
    '';
  };
}
