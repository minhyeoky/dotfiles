require("keymaps")
require("bootstrap")
require("options")

-- Enable LSP servers (Nvim 0.11+ vim.lsp.config)
-- Configs are automatically loaded from lsp/ directory
vim.lsp.enable({
  "lua_ls",
  "ruff",
  "rust_analyzer",
  "bashls",
  "dockerls",
  "graphql",
  "html",
  "jsonls",
})

-- Disable pyright (using other Python LSP)
vim.lsp.enable({ "pyright" }, false)
