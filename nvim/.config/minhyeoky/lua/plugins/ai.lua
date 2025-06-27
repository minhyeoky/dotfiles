return {
  {
    "olimorris/codecompanion.nvim",
    keys = {
      { "<leader>a", "<CMD>CodeCompanionActions<CR>", desc = "Code Companion Actions" },
    },
    opts = {
      display = {
        chat = {
          show_settings = true,
        },
      },
      strategies = {
        chat = {
          adapter = "anthropic",
        },
        inline = {
          adapter = "copilot",
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },

  {
    "github/copilot.vim",
    lazy = false,
    config = function()
      vim.g.copilot_filetypes = {
        ["*"] = true,
        ["markdown"] = false,
      }
    end,
  },

  {
    "greggh/claude-code.nvim",
     dependencies = {
     "nvim-lua/plenary.nvim",
     },
     config = function()
       require("claude-code").setup()
     end
  },
}
