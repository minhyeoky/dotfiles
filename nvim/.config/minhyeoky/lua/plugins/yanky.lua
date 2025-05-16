return {
  {
    "gbprod/yanky.nvim",
    opts = {
      highlight = {
        timer = 100,
      },
      preserve_cursor_position = {
        enabled = true,
      },
    },
    keys = {
      {
        "y",
        "<Plug>(YankyYank)",
        mode = { "n", "x" },
      },
    },
  },
}
