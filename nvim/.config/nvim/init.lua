require("keymaps")
require("bootstrap")
require("options")
require("cc-edit")

vim.lsp.config("*", {
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

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
  "vtsls",
  "yamlls",
})

-- Use virtual_lines for diagnostics (Neovim 0.11+)
vim.diagnostic.config({
  virtual_lines = true,
})

-- Site-specific overrides (optional, gitignored)
pcall(require, "local")
