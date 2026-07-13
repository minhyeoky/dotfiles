return {
  {
    "stevearc/oil.nvim",
    lazy = false,
    opts = {
      default_file_explorer = true,
    },
    config = true,
    keys = {
      {
        "<leader>fo",
        function()
          require("oil").open()
        end,
        desc = "Open oil file explorer",
      },
      {
        "<leader>fO",
        function()
          require("oil").open_float()
        end,
        desc = "Open oil file explorer (floating)",
      },
    },
  },
}
