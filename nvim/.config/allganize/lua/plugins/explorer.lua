return {
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      default_file_explorer = false,
    },
    config = true,
    keys = {
      {
        "<leader>fo",
        function()
          require("oil").open_float()
        end,
        desc = "Open Oil File Explorer (Float)",
      },
      {
        "<leader>fO",
        function()
          require("oil").open()
        end,
        desc = "Open Oil File Explorer",
      },
    },
  },
}
