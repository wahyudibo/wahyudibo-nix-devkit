local wk = require("which-key")
wk.add({
  { "<leader>f", group = "file" }, -- group for telescope
  { "<leader>q", group = "quit/session" },
  { "<leader>w", desc = "Save" },
})
