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

-- Keep diagnostic virtual_text enabled (became opt-in in Neovim 0.11)
vim.diagnostic.config({
  virtual_text = true,
})

-- Site-specific overrides (optional, gitignored)
pcall(require, "local")
