require("keymaps")
require("bootstrap")
require("options")

-- disable default Neovim LSP for Python
vim.lsp.enable({"pyright"}, false)
