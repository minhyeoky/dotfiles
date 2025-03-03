return {
  {
    "nvim-orgmode/orgmode",
    event = 'VeryLazy',
    ft = { "org" },
    config = function()
    -- Setup orgmode
    require('orgmode').setup({
      org_agenda_files = vim.env.PKM_DIR .. "/org/*",
      org_hide_leading_stars = true,
    })
  end,
  },
}
