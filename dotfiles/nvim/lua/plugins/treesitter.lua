require("nvim-treesitter.configs").setup({
  ensure_installed = { "go", "lua", "yaml", "json", "bash" },
  highlight = { enable = true },
})
