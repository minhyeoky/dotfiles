return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local configs = require("nvim-treesitter.configs")

      configs.setup({
        highlight = {
          enable = true,

          additional_vim_regex_highlighting = { "markdown" },
        },
      })
    end,
  },
}
