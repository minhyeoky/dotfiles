return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- ensure that markdown and markdown_inline are always installed
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "lua" })
      end
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "lua_ls",
      },
    },
  },
}
