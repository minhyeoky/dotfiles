return {
  {
    "tpope/vim-fugitive",
    lazy = false,
    keys = {
      {
        "<leader>gs",
        "<cmd>vertical Git<cr>",
        desc = "Git status",
      },
    },
  },

  -- extension for fugitive; adds support for GitHub
  {
    "tpope/vim-rhubarb",
    dependencies = {
      { "tpope/vim-fugitive" },
    },
    lazy = false,
  },

  {
    "lewis6991/gitsigns.nvim",
    event = "BufRead",
    opts = {
      numhl = true,
      linehl = false,
      signcolumn = false,
      word_diff = false,
    },
    config = true,
    keys = {
      {
        "<leader>ds",
        function()
          require("gitsigns").stage_hunk()
        end,
      },
      {
        "<leader>dp",
        function()
          require("gitsigns").preview_hunk()
        end,
      },
      {
        "<leader>dr",
        function()
          require("gitsigns").reset_hunk()
        end,
      },
      {
        "<leader>du",
        function()
          require("gitsigns").undo_stage_hunk()
        end,
      },
      {
        "[c",
        function()
          require("gitsigns").prev_hunk()
        end,
      },
      {
        "]c",
        function()
          require("gitsigns").next_hunk()
        end,
      },
    },
  },

  {
    "sindrets/diffview.nvim",
    config = function()
      -- local actions = require("diffview.actions")
      require("diffview").setup({
        hooks = {
          diff_buf_read = function()
            vim.opt_local.number = true
            vim.opt_local.relativenumber = false
          end,

        },
      })
    end,
  },
}
