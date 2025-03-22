return {
  {
    "github/copilot.vim",
    lazy = false,
  },
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false, -- HEAD
    opts = {
      provider = "claude",
      auto_suggestions_provider = "claude",
      -- cursor_applying_provider = "claude",
    },
    build = "make",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
  },
  {
    "olimorris/codecompanion.nvim",
    opts = {
      display = {
        chat = {
          show_settings = true,
        },
      },
      strategies = {
        chat = {
          adapter = "anthropic",
          tools = {
            ["mcp"] = {
              callback = function() return require("mcphub.extensions.codecompanion") end,
              description = "Call tools and resources from the MCP Servers",
              opts = {
                requires_approval = true,
              },
            },
          },
        },
        inline = {
          adapter = "copilot",
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",

      -- mcphub.nvim integration
      "ravitemer/mcphub.nvim",
    },
  },
}
