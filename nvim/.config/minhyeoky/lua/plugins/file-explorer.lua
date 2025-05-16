return {
  {
    "stevearc/oil.nvim",
    opts = {
      default_file_explorer = false,  -- `false` to fix netrw `GBrowse`
    },
    config = true,
    keys = {
      {
        "<leader>fo",
        function()
          require("oil").open()
        end
      },
      {
        "<leader>fO",
        function()
          require("oil").open_float()
        end
      },
    },
  },
}
