{ config, pkgs, ... }:

{
  # ── Git
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "wahyudibo";
        email = "wahyudi.ibo.wibowo@gmail.com";
      };

      gpg.format = "openpgp";
      user.signingKey = "1077A19751DD14D3";
      commit.gpgSign = true;
    };
  };

  # ── GPG Agent
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-curses;
    defaultCacheTtl = 28800;   # 8 hours
    maxCacheTtl = 86400;       # 24 hours
  };
}
