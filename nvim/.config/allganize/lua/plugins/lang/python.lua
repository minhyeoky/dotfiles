return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "python" })
      end
    end,
  },

  -- {
  --   "neovim/nvim-lspconfig",
  --   dependencies = {
  --     "mason.nvim",
  --     "williamboman/mason-lspconfig.nvim",
  --   },
  --   opts = {
  --     servers = {
  --       ruff_lsp = {}
  --     },
  --     setup = {
  --       ruff_lsp = function()
  --       end,
  --     },
  --   },
  -- },
}
