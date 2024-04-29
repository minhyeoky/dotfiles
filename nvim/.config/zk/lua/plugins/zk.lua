return {
  {
    "junegunn/fzf",
    build = "./install --bin",
  },

  {
    "ibhagwan/fzf-lua",
    dependencies = { "junegunn/fzf",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("fzf-lua").setup({
        "fzf-vim",
        defaults = {
          actions = {
            ["ctrl-s"] = require("fzf-lua").actions.file_sel_to_ll,
            ["ctrl-q"] = require("fzf-lua").actions.file_sel_to_qf,
          },
        },
      })
    end,
    keys = {
      {
        "<leader>zr",
        function()
          require("fzf-lua").grep({ search = "", cwd = vim.env.ZK_NOTEBOOK_DIR })
        end,
      },
    },
  },

  {
    "zk-org/zk-nvim",
    dependencies = {
      { "junegunn/fzf" },
      { "ibhagwan/fzf-lua" },
    },
    lazy = false,
    config = function()
      require("zk").setup({
        picker = "fzf_lua",

        lsp = {
          config = {
            cmd = { "zk", "lsp" },
            name = "zk",
          },

          auto_attach = {
            enabled = true,
            filetypes = { "markdown" },
          },
        },
      })

      -- add custom mappings
      local zk = require("zk")
      local commands = require("zk.commands")

      commands.add("ZkOrphans", function(options)
        options = vim.tbl_extend("force",
          { sort = { 'modified' }, orphan = true, tags = { 'NOT diary', 'NOT Index', 'NOT Post' } }, options or {})
        zk.edit(options, { title = "Zk Orphans" })
      end)

      -- move to the Zk directory
      require("zk").cd()
    end,
    keys = {
      {
        "<leader>zb",
        "<cmd>ZkBacklinks<cr>",
      },
      {
        "<leader>zz",
        "<cmd>ZkNotes { sort = { 'modified' }, tags = { 'Index' } }<cr>",
      },
      {
        "<leader>zn",
        "<cmd>ZkNew<cr>",
      },
      {
        "<leader>zf",
        "<cmd>ZkNotes { sort = { 'modified' } }<cr>",
      },
      {
        "<leader>zw",
        "<cmd>ZkNew { dir = '" .. vim.env.ZK_NOTEBOOK_DIR .. "/diary' }<cr>",
        desc = "New Diary",
      },
      {
        "<leader>zd",
        "<cmd>ZkNotes { sort = { 'created' }, tags = { 'diary' } }<cr>",
        desc = "List Diary",
      },
      {
        "<leader>zt",
        "<cmd>ZkTags<cr>",
      },
    },
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        sources = {
          { name = "nvim_lsp" },
          { name = "path" },
        },
        mapping = cmp.mapping.preset.insert({
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
      })
    end,
  },
}
