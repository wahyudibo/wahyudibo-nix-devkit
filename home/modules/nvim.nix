{ config, pkgs, ... }:

{
  # ── Neovim minimal setup
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;

    withPython3 = false;
    withRuby = false;

    # Essential runtime deps
    extraPackages = with pkgs; [
      # LSP
      yaml-language-server
      lua-language-server

      # Treesitter deps
      tree-sitter

      # Telescope deps
      ripgrep
      fd

      # Formatting
      stylua
      gofumpt

      # Go specifics
      gotools
    ];
  };
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/devkit/dotfiles/nvim";
}
