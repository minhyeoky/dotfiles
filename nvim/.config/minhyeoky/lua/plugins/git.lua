return {
  {
    "tpope/vim-fugitive",
    lazy = false,
    keys = {
      {
        "<leader>gg",
        "<cmd>tab Git<cr>",
        desc = "Git status",
      },
    },
  },

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
    "ruifm/gitlinker.nvim",
    dependencies =  { "nvim-lua/plenary.nvim" },
    config = function()
      require("gitlinker").setup({
        opts = {
          -- callback for what to do with the url
          action_callback = require("gitlinker.actions").copy_to_clipboard,

          print_url = false,
        },
      })
    end,
  },

  {
    "sindrets/diffview.nvim",
    config = function()
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
