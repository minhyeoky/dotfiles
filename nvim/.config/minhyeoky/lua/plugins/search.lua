return {
  {
    "junegunn/fzf",
    build = "./install --bin",
  },

  {
    "ibhagwan/fzf-lua",
    dependencies = {
      "junegunn/fzf",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("fzf-lua").setup({
        "fzf-vim",
        winopts={
          fullscreen = true,
          preview = {
            hidden = "nohidden",
            horizontal = "right:45%",
          },
        },
        defaults = {
          -- to increase performance
          file_icons = false,

          actions = {
            ["ctrl-s"] = require("fzf-lua").actions.file_sel_to_ll,
            ["ctrl-q"] = require("fzf-lua").actions.file_sel_to_qf,
          },
        },

        grep = {
          actions = {
            ["ctrl-r"] = require("fzf-lua").actions.toggle_ignore,
          },
          rg_opts = "--hidden --column --line-number --no-heading --color=always --smart-case --max-columns=256 --glob '!\\.git' --glob '!\\.idea' --glob '!\\tags' --glob '!\\tags.temp' --glob='!{.git,.svn,node_modules,tealdeer,Trash,vendor}' --glob '!*.lock' --glob='!{package-lock.json}' --no-ignore -e",
        },
      })
    end,
    keys = {
      {
        "<leader>fr",
        function()
          require("fzf-lua").live_grep({ search = "" })
        end,
        desc = "Live Grep",
      },
      {
        "<leader>fR",
        function()
          require("fzf-lua").live_grep_resume()
        end,
        desc = "Live Grep Resume",
      },
      {
        "<leader>ft",
        function()
          require("fzf-lua").tags()
        end,
        desc = "Tags",
      },
      {
        "<leader>ff",
        function()
          require("fzf-lua").files()
        end,
        desc = "Files",
      },
      {
        "<leader>fb",
        function()
          require("fzf-lua").buffers()
        end,
        desc = "Buffers",
      },
      {
        "<leader>df",
        function()
          require("fzf-lua").files({ cwd = vim.fn.stdpath("config") })
        end,
        desc = "Dot Files",
      },
    },
  },
}
