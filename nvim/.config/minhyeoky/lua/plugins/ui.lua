return {
  {
    "sphamba/smear-cursor.nvim",
    opts = {},
  },
  {
    "karb94/neoscroll.nvim",
    config = function()
      require("neoscroll").setup({
          mappings = {
          '<C-u>', '<C-d>',
          '<C-b>', '<C-f>',
          '<C-y>', '<C-e>',
          -- 'zt', 'zz', 'zb',
        },
        duration_multiplier = 0.5,
      })
    end
  },
}
