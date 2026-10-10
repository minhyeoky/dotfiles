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
    -- tmux session/window/pane 을 oil 처럼 버퍼로 편집. 검증 전 플러그인이라 커밋 고정.
    "asdf8601/tmux-oil.nvim",
    commit = "4bf5b493902b7cefe39c9a0f1878c9ac60fd6541",
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
