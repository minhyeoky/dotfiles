return {
  {
    "ludovicchabant/vim-gutentags",
    lazy = false,
  },

  {
    "github/copilot.vim",
    lazy = false,
  },

  {
    "junegunn/fzf",
  },
  build = "./install --bin",

  {
    "ibhagwan/fzf-lua",
    dependencies = {
      "junegunn/fzf",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("fzf-lua").setup({
        "fzf-vim",
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
        "<leader>fr",
        '<cmd>:lua require("fzf-lua").grep({ search = "" })<cr>',
        desc = "Grep",
      },
      {
        "<leader>ft",
        '<cmd>lua require("fzf-lua").tags()<cr>',
        desc = "Tags",
      },
      {
        "<leader>ff",
        '<cmd>:lua require("fzf-lua").files()<cr>',
        desc = "Files",
      },
      {
        "<leader>fb",
        '<cmd>:lua require("fzf-lua").buffers()<cr>',
        desc = "Buffers",
      },
    },
  },

  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = true,
    keys = {
      {
        "<leader>a",
        function()
          require("harpoon"):list():add()
        end,
      },
      {
        "<leader>e",
        function()
          require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
        end,
      },
    },
  },
}
