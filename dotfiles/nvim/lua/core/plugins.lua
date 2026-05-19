local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath
  })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- LSP
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("plugins.lsp")
    end
  },

  -- Autocomplete
  { "hrsh7th/nvim-cmp",
     dependencies = {
       "hrsh7th/cmp-nvim-lsp",
       "L3MON4D3/LuaSnip",
     },
     config = function()
       require("plugins.cmp")
     end
  },

  -- Telescope (fzf inside nvim)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("plugins.telescope")
    end
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSInstall go lua yaml json bash toml markdown dockerfile terraform hcl",
    config = function()
      require("plugins.treesitter")
    end
  },

  -- Harpoon (Fast file switching)
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("plugins.harpoon")
    end,
  },

  -- Oil.nvim (Edit file system like a buffer)
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("plugins.oil")
    end,
  },

  -- Which-key (Popup for keybindings)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    config = function(_, opts)
      require("which-key").setup(opts)
      require("plugins.which-key")
    end,
  },

  -- UI
  { "nvim-lualine/lualine.nvim", opts = {} },

  -- Git
  { "lewis6991/gitsigns.nvim", opts = {} },

  -- Comment
  { "numToStr/Comment.nvim", opts = {} },
})
