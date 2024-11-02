return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- ensure that markdown and markdown_inline are always installed
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "org" })
      end
    end,
  },

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
