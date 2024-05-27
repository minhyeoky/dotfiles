function setup_autobrackets(cmp, opts)
  local Kind = cmp.lsp.CompletionItemKind
  cmp.event:on("confirm_done", function(event)
    -- if not vim.tbl_contains(opts.auto_brackets or {}, vim.bo.filetype) then
    --   return
    -- end
    local entry = event.entry
    local item = entry:get_completion_item()
    if vim.tbl_contains({ Kind.Function, Kind.Method }, item.kind) then
      local keys = vim.api.nvim_replace_termcodes("()<left>", false, false, true)
      vim.api.nvim_feedkeys(keys, "i", true)
    end
  end)
end

return {
  {
    "hrsh7th/nvim-cmp",
    version = false,
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
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
          { name = "buffer" },
          { name = "path" },
        }),
        completion = {
          completeopt = "menu,menuone,noselect",
        },
        sorting = defaults.sotring,
      }
    end,
    config = function(_, opts)
      for _, source in ipairs(opts.sources) do
        source.group_index = source.group_index or 1
      end

      local cmp = require("cmp")
      cmp.setup(opts)
      setup_autobrackets(cmp, opts)
    end,
  },
}
