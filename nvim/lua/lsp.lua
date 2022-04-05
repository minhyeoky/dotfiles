-- Configurations: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md

-- npm install -g pyright
require('lspconfig').pyright.setup{
  settings = {
    python = {
      analysis = {
        diagnosticMode = "workspace",
      }
    }
  }
}

-- https://github.com/sumneko/lua-language-server/wiki/Build-and-Run
-- brew install lua-language-server
require("lspconfig").sumneko_lua.setup{
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = "LuaJIT",
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { "vim" },
      }
    }
  }
}

-- https://github.com/hrsh7th/vscode-langservers-extracted
-- npm install -g vscode-langservers-extracted
require("lspconfig").jsonls.setup{}

-- https://github.com/mads-hartmann/bash-language-server
-- npm install -g bash-language-server
require'lspconfig'.bashls.setup{}

