return {
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

  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      copilot_model = "gpt-4o-copilot",
      filetypes = {
        python = true,
        markdown = true,
        sh = function ()
          if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), '^%.env.*') then
            -- disable for .env files
            return false
          end
          return true
        end,
        ["*"] = false,
      },
    },
    config = true,
  },
}
