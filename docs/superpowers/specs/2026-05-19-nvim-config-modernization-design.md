# Neovim Config Modernization — Design Spec

**Date:** 2026-05-19
**Scope:** Full modernization (C)

---

## Context

The neovim configuration lives in `dotfiles/nvim/` and is symlinked into `~/.config/nvim` via `xdg.configFile."nvim"` in `home/modules/nvim.nix`. LSPs and formatters are installed by nix (no Mason). Lua config entry point is `dotfiles/nvim/init.lua` which loads `core.options`, `core.keymaps`, `core.plugins`. Plugins are managed by lazy.nvim.

---

## Goals

1. Fix all currently broken/unwired plugin configurations
2. Remove nvim-tree in favour of oil.nvim
3. Remap harpoon jump keys away from split-navigation conflicts
4. Add LSP keymaps, quality-of-life options, Tab completion cycling
5. Add catppuccin-mocha colorscheme
6. Fix deprecated `vim.loop` → `vim.uv`
7. Expand treesitter parser list
8. Restore terraform LSP support (terraform-ls + terraformls config)

---

## Section 1 — Plugin List (`plugins.lua`)

### Bugs to fix

| Bug | Fix |
|-----|-----|
| `require("plugins.harpoon"):setup()` — harpoon.lua returns nil | Change to `require("plugins.harpoon")` |
| oil.nvim: `opts = {}` only, `plugins/oil.lua` keymap file never loaded | Drop `opts = {}`, add `config = function() require("plugins.oil") end` |
| which-key: `opts = {}` only, `plugins/which-key.lua` groups never registered | Keep `opts = {}`, add `config = function(_, opts) require("which-key").setup(opts); require("plugins.which-key") end` |
| gitsigns, lualine, Comment.nvim: no `config` or `opts` — setup() never called | Add `opts = {}` to each |
| `vim.loop.fs_stat` deprecated | Change to `vim.uv.fs_stat` |

### Removals

- `nvim-tree/nvim-tree.lua` — replaced by oil.nvim
- `kyazdani42/nvim-web-devicons` — duplicate; oil.nvim already depends on `nvim-tree/nvim-web-devicons`

### Additions

- `catppuccin/nvim` with `name = "catppuccin"`, `priority = 1000`, `opts = { flavour = "mocha" }`

---

## Section 2 — Options (`core/options.lua`)

Add to the existing 6 options:

```lua
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.clipboard = "unnamedplus"
vim.opt.wrap = false
vim.opt.cursorline = true
vim.opt.splitright = true
vim.opt.splitbelow = true
```

---

## Section 3 — Keymaps (`core/keymaps.lua`)

### Removals

- `<leader>e` → NvimTreeToggle (nvim-tree removed)

### Changes

- `<C-j>` / `<C-k>` quickfix nav → `]q` / `[q` (standard, no conflicts)

### Additions

- Window navigation: `<C-h/j/k/l>` → `<C-w>h/j/k/l` (safe now that `<C-h>` is freed from harpoon)
- `silent = true` added to all keymaps

### Colorscheme activation

```lua
vim.cmd.colorscheme("catppuccin-mocha")
```

Added at the bottom of `init.lua`, after all three `require(...)` calls. The colorscheme must be set after `require("core.plugins")` so that catppuccin is loaded by lazy.nvim before the theme is applied.

---

## Section 4 — LSP (`plugins/lsp.lua`)

### Terraform restored

`terraform-ls` is added back to `nvim.nix` extraPackages and `terraformls` configuration is kept in `plugins/lsp.lua`. This requires `just apply` (nix rebuild). The `terraform` and `hcl` parsers are also added to treesitter `ensure_installed`.

### Additions

`LspAttach` autocmd that registers keymaps scoped to the attached buffer:

| Key | Action | Mode |
|-----|--------|------|
| `gd` | `vim.lsp.buf.definition()` | n |
| `gr` | `vim.lsp.buf.references()` | n |
| `K` | `vim.lsp.buf.hover()` | n |
| `<leader>rn` | `vim.lsp.buf.rename()` | n |
| `<leader>ca` | `vim.lsp.buf.code_action()` | n |
| `[d` | `vim.diagnostic.goto_prev()` | n |
| `]d` | `vim.diagnostic.goto_next()` | n |

All keymaps use `{ buffer = bufnr, silent = true, desc = "..." }`.

---

## Section 5 — Harpoon (`plugins/harpoon.lua`)

### Changes

- Add `harpoon:setup()` call at the top of the file
- Change jump keys from `<C-h/t/n/s>` → `<leader>1/2/3/4`
- Change menu toggle from `<C-e>` → `<leader>h`

### Final keymaps

| Key | Action |
|-----|--------|
| `<leader>a` | harpoon add file |
| `<leader>h` | harpoon menu |
| `<leader>1` | jump to slot 1 |
| `<leader>2` | jump to slot 2 |
| `<leader>3` | jump to slot 3 |
| `<leader>4` | jump to slot 4 |

---

## Section 6 — CMP (`plugins/cmp.lua`)

Add Tab/S-Tab for cycling completions:

```lua
["<Tab>"] = cmp.mapping(function(fallback)
  if cmp.visible() then cmp.select_next_item() else fallback() end
end, { "i", "s" }),
["<S-Tab>"] = cmp.mapping(function(fallback)
  if cmp.visible() then cmp.select_prev_item() else fallback() end
end, { "i", "s" }),
["<C-e>"] = cmp.mapping.abort(),
```

---

## Section 7 — Treesitter (`plugins/treesitter.lua`)

Add to `ensure_installed`:
- `toml`
- `markdown`
- `dockerfile`
- `terraform` (restored with terraform LSP)
- `hcl` (HCL syntax used by terraform)

---

## Section 8 — Which-key (`plugins/which-key.lua`)

Expand group registrations:

| Prefix | Group label | Notes |
|--------|------------|-------|
| `<leader>f` | file | telescope find/grep/buffers |
| `<leader>r` | refactor | rename, etc. |
| `<leader>c` | code | code actions |
| `<leader>q` | quit | |
| `]` | next | diagnostics, quickfix |
| `[` | prev | diagnostics, quickfix |

Individual key descs (not groups):

| Key | Desc |
|-----|------|
| `<leader>w` | Save |
| `<leader>a` | Harpoon: add file |
| `<leader>h` | Harpoon: menu |
| `<leader>1-4` | Harpoon: jump to slot N |

---

## Files Changed

| File | Change type |
|------|-------------|
| `dotfiles/nvim/init.lua` | Add colorscheme call at end |
| `dotfiles/nvim/lua/core/options.lua` | Add 8 options |
| `dotfiles/nvim/lua/core/keymaps.lua` | Remove nvim-tree keymap, remap quickfix, add window nav, add silent=true |
| `dotfiles/nvim/lua/core/plugins.lua` | Fix harpoon/oil/which-key configs, add catppuccin, add opts to gitsigns/lualine/Comment, remove nvim-tree, fix vim.uv |
| `dotfiles/nvim/lua/plugins/lsp.lua` | Restore terraformls, add LspAttach keymaps |
| `home/modules/nvim.nix` | Add terraform-ls back to extraPackages (**requires `just apply`**) |
| `dotfiles/nvim/lua/plugins/harpoon.lua` | Add setup(), remap jump keys |
| `dotfiles/nvim/lua/plugins/cmp.lua` | Add Tab/S-Tab/C-e |
| `dotfiles/nvim/lua/plugins/treesitter.lua` | Add parsers |
| `dotfiles/nvim/lua/plugins/which-key.lua` | Expand groups |

**One nix rebuild required:** `home/modules/nvim.nix` adds `terraform-ls` back to extraPackages. Run `just apply` after that change. All other changes are in Lua dotfiles symlinked live and take effect immediately.

---

## Out of Scope

- Adding additional LSP servers beyond the restored set (requires `nvim.nix` change + `just apply`)
- Formatter integration with null-ls / conform.nvim
- DAP / debugging setup
- Snippets beyond LuaSnip passthrough
