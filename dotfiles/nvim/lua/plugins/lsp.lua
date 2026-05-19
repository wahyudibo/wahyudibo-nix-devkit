-- terraformls binary is 'terraform-ls serve', not the default
vim.lsp.config("terraformls", {
  cmd = { "terraform-ls", "serve" },
})

vim.lsp.enable({ "gopls", "terraformls", "yamlls", "lua_ls" })
