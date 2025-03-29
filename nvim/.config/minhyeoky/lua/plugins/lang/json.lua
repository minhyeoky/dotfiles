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
    dependencies = {
      "b0o/schemastore.nvim",
    },
    opts = {
      -- capabilities = capabilities,
      servers = {
        jsonls = {
          -- https://www.npmjs.com/package/vscode-json-languageserver#settings
          settings = {
            json = {
              format = {
                enable = true,
              },
              schemas = require("schemastore").json.schemas({
                -- https://github.com/SchemaStore/schemastore/blob/master/src/api/json/catalog.json
                select = {
                  "package.json",
                },
                extra = {
                  -- FIXME: this schema is not working
                  {
                    description = "Code Companion Workspace",
                    fileMatch = { "codecompanion-workspace.json" },
                    url = "https://raw.githubusercontent.com/olimorris/codecompanion.nvim/refs/heads/main/lua/codecompanion/workspace-schema.json",
                    name = "codecompanion-workspace.json",
                  },
                }
              }),
              -- https://github.com/b0o/SchemaStore.nvim/issues/8
              validate = { enable = true },
            },
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
