return {
  {
    "stevearc/oil.nvim",
    config = true,
    keys = {
      {
        "<leader>fo",
        function()
          require("oil").open_float()
        end
      },
    },
  },
}
