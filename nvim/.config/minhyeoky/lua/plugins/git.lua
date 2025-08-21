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

      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
        delay = 10,
        ignore_whitespace = false,
        virt_text_priority = 100,
      },
    },
    config = true,
    keys = {
      {
        "<leader>ds",
        function()
          require("gitsigns").stage_hunk()
        end,
        desc = "Stage hunk",
      },
      {
        "<leader>dp",
        function()
          require("gitsigns").preview_hunk()
        end,
        desc = "Preview hunk",
      },
      {
        "<leader>dr",
        function()
          require("gitsigns").reset_hunk()
        end,
        desc = "Reset hunk",
      },
      {
        "<leader>du",
        function()
          require("gitsigns").undo_stage_hunk()
        end,
        desc = "Undo stage hunk",
      },
      {
        "[c",
        function()
          require("gitsigns").prev_hunk()
        end,
        desc = "Previous hunk",
      },
      {
        "]c",
        function()
          require("gitsigns").next_hunk()
        end,
        desc = "Next hunk",
      },
      {
        ",vw",
        function()
          require("gitsigns").toggle_word_diff()
        end,
        desc = "Toggle word diff highlighting",
      },
      {
        ",vh",
        function()
          require("gitsigns").preview_hunk_inline()
        end,
        desc = "Preview hunk inline",
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
    keys = {
      {
        "<leader>gdd",
        "<cmd>DiffviewOpen<cr>",
        desc = "Open Diffview",
      },
      {
        ",hh",
        "<cmd>DiffviewFileHistory<cr>",
        desc = "Trace repository history",
      },
      {
        ",hf",
        "<cmd>DiffviewFileHistory %<cr>",
        desc = "Trace current file history",
      },
      {
        ",hl",
        "<cmd>DiffviewFileHistory %<cr>",
        mode = "n",
        desc = "Trace current line history",
      },
      {
        ",hl",
        ":<C-u>'<,'>DiffviewFileHistory<cr>",
        mode = "v",
        desc = "Trace selection history",
      },
      {
        ",d",
        "<cmd>DiffviewOpen<cr>",
        desc = "Diff working directory against HEAD",
      },
      {
        ",hm",
        "<cmd>DiffviewOpen HEAD~1<cr>",
        desc = "Diff against local master",
      },
      {
        ",hM",
        "<cmd>DiffviewOpen origin/master<cr>",
        desc = "Diff against remote master",
      },
      {
        ",vc",
        function()
          local clipboard_content = vim.fn.getreg('+')
          local temp_file = vim.fn.tempname()
          vim.fn.writefile(vim.split(clipboard_content, '\n'), temp_file)
          vim.cmd('DiffviewOpen ' .. temp_file)
        end,
        mode = "n",
        desc = "Compare clipboard with current file",
      },
      {
        ",vc",
        function()
          local clipboard_content = vim.fn.getreg('+')
          local temp_file = vim.fn.tempname()
          vim.fn.writefile(vim.split(clipboard_content, '\n'), temp_file)
          
          -- Get visual selection
          local start_pos = vim.fn.getpos("'<")
          local end_pos = vim.fn.getpos("'>")
          local lines = vim.fn.getline(start_pos[2], end_pos[2])
          
          -- Create temp file with selection
          local selection_file = vim.fn.tempname()
          vim.fn.writefile(lines, selection_file)
          
          vim.cmd('DiffviewOpen ' .. selection_file .. ' ' .. temp_file)
        end,
        mode = "v",
        desc = "Compare clipboard with selection",
      },
    },
  },

  {
    "ldelossa/gh.nvim",
    dependencies = {
        {
        "ldelossa/litee.nvim",
        config = function()
            require("litee.lib").setup()
        end,
        },
    },
    config = function()
        require("litee.gh").setup()
    end,
  },
}
