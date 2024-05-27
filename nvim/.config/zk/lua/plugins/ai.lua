return {
  {
    "robitx/gp.nvim",
    config = function()
      require("gp").setup({
        cmd_prefix = "",
        chat_dir = vim.env.ZK_NVIM_GP_CHAT_DIR,
      })
    end,
  }
}
