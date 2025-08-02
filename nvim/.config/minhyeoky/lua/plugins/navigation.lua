return {
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      search = {
        mode = "fuzzy",
      },
    },
    keys = {
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    },
  },
}
