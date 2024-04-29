return {
  {
    "stevearc/oil.nvim",
    config = true,
  },

  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
      { "stevearc/oil.nvim" },
    },
    config = function()
      require("dashboard").setup({
        theme = "doom",
        config = {
          header = {
            "",
            "",
            "███████╗██╗  ██╗",
            "╚══███╔╝██║ ██╔╝",
            "  ███╔╝ █████╔╝ ",
            " ███╔╝  ██╔═██╗ ",
            "███████╗██║  ██╗",
            "╚══════╝╚═╝  ╚═╝",
            "",
            "",
          },
          center = {
            {
              icon = "",
              desc = 'Index',
              key = 'i',
              key_format = ' [%s]', -- `%s` will be substituted with value of `key`
              action = function()
                require("zk").edit(
                  {
                    sort = { "modified" },
                    tags = { "Index" },
                  },
                  { title = "Zk Index" }
                )
              end,
            },
            {
              icon = "",
              desc = 'New Note',
              key = 'n',
              key_format = ' [%s]', -- `%s` will be substituted with value of `key`
              action = function()
                require("zk").new()
              end,
            },
            {
              icon = "",
              desc = 'Notes',
              key = 'f',
              key_format = ' [%s]', -- `%s` will be substituted with value of `key`
              action = function()
                require("zk").edit(
                  {
                    sort = { "modified" },
                    excludeHrefs = { vim.env.ZK_NOTEBOOK_DIR .. "/diary" },
                  },
                  { title = "Zk Notes" }
                )
              end,
            },
            {
              icon = "",
              desc = 'New Diary',
              key = 'w',
              key_format = ' [%s]', -- `%s` will be substituted with value of `key`
              action = function()
                require("zk").new({
                  dir = vim.env.ZK_NOTEBOOK_DIR .. "/diary",
                })
              end,
            },
            {
              icon = "",
              desc = 'Diaries',
              key = 'd',
              key_format = ' [%s]', -- `%s` will be substituted with value of `key`
              action = function()
                require("zk").edit(
                  {
                    sort = { "created" },
                    tags = { "diary" },
                  },
                  { title = "Zk Diaries" }
                )
              end,
            },
            {
              icon = "",
              desc = 'Config (Explorer)',
              key = 'ce',
              key_format = ' [%s]', -- `%s` will be substituted with value of `key`
              action = function()
                require("oil").open_float(vim.fn.stdpath("config"))
              end,
            },
            {
              icon = "",
              desc = 'Config (Files)',
              key = 'cf',
              key_format = ' [%s]', -- `%s` will be substituted with value of `key`
              action = function()
                require("fzf-lua").files({
                  cwd = vim.fn.stdpath("config"),
                })
              end,
            },
          },
          footer = function()
            return {
              vim.loop.cwd(),
            }
          end,
        }
      })
    end,
  },
}
