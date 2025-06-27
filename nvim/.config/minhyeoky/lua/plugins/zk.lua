return {
  {
    "zk-org/zk-nvim",
    dependencies = {
      { "junegunn/fzf" },
      { "ibhagwan/fzf-lua" },
    },
    lazy = false,
    config = function()
      require("zk").setup({
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
    end,
    keys = {
      {
        "<leader>zb",
        "<cmd>ZkBacklinks<cr>",
      },
      {
        "<leader>zz",
        "<cmd>ZkNotes { sort = { 'modified' }, tags = { 'Index', 'NOT Archive' } }<cr>",
      },
      {
        "<leader>zn",
        "<cmd>ZkNew<cr>",
      },
      {
        "<leader>zf",
        "<cmd>ZkNotes { sort = { 'modified' }, tags = { 'NOT Archive' } }<cr>",
      },
      {
        "<leader>zw",
        "<cmd>ZkNew { dir = '" .. vim.env.ZK_NOTEBOOK_DIR .. "/diary' }<cr>",
        desc = "New Diary",
      },
      {
        "<leader>zd",
        "<cmd>ZkNotes { sort = { 'created' }, tags = { 'diary', 'NOT Archive' } }<cr>",
        desc = "List Diary",
      },
      {
        "<leader>zt",
        "<cmd>ZkTags<cr>",
      },
    },
  },

  -- {
  --   "hrsh7th/nvim-cmp",
  --   dependencies = {
  --     "hrsh7th/cmp-nvim-lsp",
  --     "hrsh7th/cmp-path",
  --   },
  --   config = function()
  --     local cmp = require("cmp")
  --     cmp.setup({
  --       sources = {
  --         { name = "nvim_lsp" },
  --         { name = "path" },
  --       },
  --       mapping = cmp.mapping.preset.insert({
  --         ["<CR>"] = cmp.mapping.confirm({ select = true }),
  --       }),
  --     })
  --   end,
  -- },
}
