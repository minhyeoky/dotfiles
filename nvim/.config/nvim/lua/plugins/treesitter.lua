return {
  -- nvim-treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = ":TSUpdate",
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      folds = { enable = true },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)

      -- markdown foldmethod, expr with treesitter
      vim.api.nvim_create_autocmd({ "FileType" }, {
        pattern = { "markdown" },
        callback = function()
          vim.opt_local.foldmethod = "expr"
          vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.opt_local.foldenable = true
          vim.opt_local.foldlevel = 2
        end,
      })
    end,
  },

  -- nvim-treesitter-textobjects (new API)
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")
      local swap = require("nvim-treesitter-textobjects.swap")
      local ts = "textobjects"

      -- Select
      local select_maps = {
        ["af"] = "@function.outer", ["if"] = "@function.inner",
        ["ac"] = "@class.outer",    ["ic"] = "@class.inner",
        ["aa"] = "@parameter.outer", ["ia"] = "@parameter.inner",
        ["al"] = "@loop.outer",     ["il"] = "@loop.inner",
        ["ai"] = "@conditional.outer", ["ii"] = "@conditional.inner",
        ["a="] = "@assignment.outer", ["i="] = "@assignment.rhs",
      }
      for key, query in pairs(select_maps) do
        vim.keymap.set({ "x", "o" }, key, function()
          select.select_textobject(query, ts)
        end)
      end

      -- Move
      local move_maps = {
        { "]m", "goto_next_start", "@function.outer" },
        { "]]", "goto_next_start", "@class.outer" },
        { "]M", "goto_next_end", "@function.outer" },
        { "][", "goto_next_end", "@class.outer" },
        { "[m", "goto_previous_start", "@function.outer" },
        { "[[", "goto_previous_start", "@class.outer" },
        { "[M", "goto_previous_end", "@function.outer" },
        { "[]", "goto_previous_end", "@class.outer" },
      }
      for _, m in ipairs(move_maps) do
        vim.keymap.set({ "n", "x", "o" }, m[1], function()
          move[m[2]](m[3], ts)
        end)
      end

      -- Swap
      vim.keymap.set("n", "<leader>a", function()
        swap.swap_next("@parameter.inner")
      end)
      vim.keymap.set("n", "<leader>A", function()
        swap.swap_previous("@parameter.inner")
      end)
    end,
  },
}
