return {
  {
    {
      "luisiacc/gruvbox-baby",
      branch = "main",
      config = function()
        vim.o.background = "dark"
        vim.g.gruvbox_baby_transparent_mode = 1
        --vim.cmd([[colorscheme gruvbox-baby]])
      end,
    },
  },

  {
    "folke/tokyonight.nvim",
    lazy = false,
    opts = {},
    config = function()
      --vim.cmd[[colorscheme tokyonight]]
    end,
  },

  {
    "ellisonleao/gruvbox.nvim",
    config = function()
      require("gruvbox").setup({
        transparent_mode = true,
      })
      vim.cmd[[colorscheme gruvbox]]
    end,
  },
}
