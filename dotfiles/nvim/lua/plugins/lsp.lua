local lspconfig = require("lspconfig")

-- Go
lspconfig.gopls.setup {}

-- Terraform
lspconfig.terraformls.setup {
  cmd = { "terraform-ls", "serve" },
}

-- YAML (Kubernetes)
lspconfig.yamlls.setup {}

-- Lua (for config)
lspconfig.lua_ls.setup {}
