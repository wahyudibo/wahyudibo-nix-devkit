require("nvim-treesitter").setup()

-- treesitter highlight is built into Neovim 0.11+; start it for every filetype
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})
