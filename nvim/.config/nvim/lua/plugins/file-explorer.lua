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
  {
    -- tmux window 목록을 oil 처럼 버퍼로 편집 (자체 구현, private).
    "minhyeoky/tmux-oil.nvim",
    cmd = "TmuxOil",
    opts = {},
    keys = {
      {
        "<leader>fm",
        function()
          require("tmux-oil").open()
        end,
        desc = "Edit tmux windows/panes as a buffer",
      },
    },
  },
}
