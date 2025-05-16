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
        },
      })
    end,
    keys = {
      {
        "<leader>ft",
        function()
          require("fzf-lua").tags()
        end,
        desc = "Tags",
      },
    },
  },
}
