return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(
          opts.ensure_installed,
          {
            "dockerfile",
          }
        )
      end
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      -- capabilities = capabilities,
      servers = {
        dockerls = {
          -- https://www.npmjs.com/package/vscode-json-languageserver#settings
          settings = {
            docker = {
              languageserver = {
                formatter = {
                  ignoreMultilineInstructions = true,
                },
              },
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
        "dockerls",
      },
    },
  },
}
