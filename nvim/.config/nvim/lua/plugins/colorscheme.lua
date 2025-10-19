return {
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
