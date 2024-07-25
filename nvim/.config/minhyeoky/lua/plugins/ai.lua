return {
  -- add copilot
  -- {
  --   "hrsh7th/nvim-cmp",
  --   dependencies = {
  --     {
  --       "zbirenbaum/copilot-cmp",
  --       dependencies = {
  --         {
  --           "zbirenbaum/copilot.lua",
  --           event = "InsertEnter",
  --           cmd = "Copilot",
  --           opts = {
  --             filetypes = {
  --               ledger = false,
  --             },
  --           },
  --           config = function(_, opts)
  --             require("copilot").setup(opts)
  --           end
  --         },
  --       },
  --       opts = {},
  --       config = function (_, opts)
  --         require("copilot_cmp").setup(opts)
  --       end
  --     },
  --   },
  --   opts = function (_, opts)
  --     table.insert(
  --       opts.sources,
  --       {
  --         name = "copilot",
  --         priority = 100,
  --         group_index = 1,
  --       }
  --     )
  --   end
  -- },
  {
    "github/copilot.vim",
    lazy = false,
  },
}
