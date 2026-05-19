{ config, pkgs, ... }:

{
  # ── Neovim minimal setup
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;

    # Use Lua config
    extraLuaConfig = ''
      require("core.options")
      require("core.keymaps")
      require("core.plugins")
    '';

    withPython3 = false;
    withRuby = false;

    # Essential runtime deps
    extraPackages = with pkgs; [
      # LSP
      gopls
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
      golangci-lint
    ];
  };
  xdg.configFile."nvim".source = ./../../dotfiles/nvim;
}
