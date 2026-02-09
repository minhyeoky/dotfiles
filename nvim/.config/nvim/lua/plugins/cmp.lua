return {
  {
    "hrsh7th/nvim-cmp",
    version = false,
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "kirasok/cmp-hledger",
    },
    opts = function()
      local cmp = require("cmp")
      local defaults = require("cmp.config.default")()

      return {
        -- auto_brackets = {},  -- any filetypes
        mapping = {
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-CR>"] = function(fallback)
            cmp.abort()
            fallback()
          end,
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "copilot" },
          { name = "buffer" },
          { name = "path" },
          { name = "hledger" },
        }),
        completion = {
          completeopt = "menu,menuone,noselect",
        },
        sorting = defaults.sorting,
        performance = {
          -- due to AI tools
          fetching_timeout = 2000,
        },
      }
    end,
    config = function(_, opts)
      for _, source in ipairs(opts.sources) do
        source.group_index = source.group_index or 1
      end

      local cmp = require("cmp")
      cmp.setup(opts)
    end,
  },

  {
    "zbirenbaum/copilot-cmp",
    config = true,
  }
}
