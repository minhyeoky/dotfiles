return {
  {
    {
      "luisiacc/gruvbox-baby",
      branch = "main",
      priority = 1000,
      config = function()
        vim.o.background = "dark"
        vim.g.gruvbox_baby_transparent_mode = 1
        vim.cmd([[colorscheme gruvbox-baby]])
      end,
    },
  },
}
