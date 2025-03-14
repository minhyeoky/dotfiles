-- local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities.textDocument.completion.completionItem.snippetSupport = true

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(
          opts.ensure_installed,
          {
            "json",
            "jsonc",
          }
        )
      end
    end,
  },

  {
    "neovim/nvim-lspconfig",
    -- dependencies = {
    --   "b0o/schemastore.nvim",
    -- },
    opts = {
      -- capabilities = capabilities,
      servers = {
        jsonls = {
          -- https://www.npmjs.com/package/vscode-json-languageserver#settings
          settings = {
            -- FIXME: adding json configuration makes the server stop working
            -- json = {
            --   schemas = {},
            -- },
          },
        },
      },
    },
  },

  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "jsonls",
      },
    },
  },
}
