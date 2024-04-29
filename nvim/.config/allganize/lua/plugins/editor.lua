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

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
    },
    config = function()
      require("cmp").setup({
        mapping = {
          ["<C-n>"] = require("cmp").mapping.select_next_item({
            behavior = require("cmp").SelectBehavior.Insert,
          }),
          ["<C-p>"] = require("cmp").mapping.select_prev_item({
            behavior = require("cmp").SelectBehavior.Insert,
          }),
          ["<C-d>"] = require("cmp").mapping.scroll_docs(-4),
          ["<C-f>"] = require("cmp").mapping.scroll_docs(4),
          ["<CR>"] = require("cmp").mapping.confirm({
            select = true,
          }),
        },
        sources = {
          { name = "nvim_lsp" },
        },
      })
    end,
  },
}
