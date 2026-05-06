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
    };
  };
}
