return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(
          opts.ensure_installed,
          {
            "python",
            "toml",
            "rst",
            "ninja",
            "htmldjango",
          }
        )
      end
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          settings = {
            python = {
              analysis = {
                diagnosticMode = "workspace",
              },
            },
          },
        },
        ruff_lsp = {},
      },
    }
  },
}
