return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = ":TSUpdate",
    opts = {
      ensure_installed = "all",
      highlight = { enable = true },
      indent = { enable = true },
      folds = { enable = true },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)

      -- markdown foldmethod, expr with treesitter
      vim.api.nvim_create_autocmd({ "FileType" }, {
        pattern = { "markdown" },
        callback = function()
          vim.opt_local.foldmethod = "expr"
          vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.opt_local.foldenable = true
          vim.opt_local.foldlevel = 2
        end,
      })
    end,
  },
}
