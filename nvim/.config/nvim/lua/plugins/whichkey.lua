return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      -- git 키맵 그룹라벨 — ,g 팝업에서 하위 갈래를 이름으로 보여줘 탐색으로 찾게 한다
      spec = {
        { "<leader>g", group = "git" },
        { "<leader>gd", group = "diff" },
        { "<leader>gh", group = "history" },
        { "<leader>gs", group = "stage/hunk" },
        { "<leader>gr", group = "review" },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  }
}
