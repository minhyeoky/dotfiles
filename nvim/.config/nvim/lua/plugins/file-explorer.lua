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
    -- tmux window 목록을 oil 처럼 버퍼로 편집 (자체 구현). private repo 라 SSH 로 받는다 —
    -- lazy 의 HTTPS clone 은 프롬프트 없이 실패한다.
    "minhyeoky/tmux-oil.nvim",
    url = "git@github.com:minhyeoky/tmux-oil.nvim.git", -- gitguard-ok: SSH remote, not an email
    cmd = "TmuxOil",
    opts = { follow_cursor = true }, -- 커서를 옮기면 popup 뒤 window 도 따라간다; q 는 원래 window 로 복귀
    keys = {
      {
        "<leader>fm",
        function()
          require("tmux-oil").open()
        end,
        desc = "Edit tmux windows as a buffer",
      },
    },
  },
}
