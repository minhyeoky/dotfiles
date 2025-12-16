require("keymaps")
require("bootstrap")
require("options")

vim.lsp.enable({
  "lua_ls",
  "ruff",
  "rust_analyzer",
  "bashls",
  "dockerls",
  "graphql",
  "html",
  "jsonls",
  "pyright",
})

-- Site-specific overrides (optional, gitignored)
pcall(require, "local")
