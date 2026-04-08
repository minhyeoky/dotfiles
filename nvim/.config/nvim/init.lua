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

-- Use virtual_lines for diagnostics (Neovim 0.11+)
vim.diagnostic.config({
  virtual_lines = true,
})

-- Site-specific overrides (optional, gitignored)
pcall(require, "local")
