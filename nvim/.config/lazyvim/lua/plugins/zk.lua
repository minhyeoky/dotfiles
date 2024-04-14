return {
  {
    "zk-org/zk-nvim",
    config = function(_, opts)
      require("zk").setup({
        picker = "telescope",
        lsp = {
          -- `config` is passed to `vim.lsp.start_client(config)`
          config = {
            cmd = { "zk", "lsp" },
            name = "zk",
            -- on_attach = ...
            -- etc, see `:h vim.lsp.start_client()`
          },

          -- automatically attach buffers in a zk notebook that match the given filetypes
          auto_attach = {
            enabled = true,
            filetypes = { "markdown" },
          },
        },
      })
      local zk_notebook_dir = vim.env.ZK_NOTEBOOK_DIR
      local lsp_map_opts = { noremap = true, silent = true }
      vim.api.nvim_set_keymap("n", "<leader>zb", "<Cmd>ZkBacklinks<CR>", lsp_map_opts)
      vim.api.nvim_set_keymap("n", "<leader>zn", "<Cmd>ZkNew<CR>", lsp_map_opts)
      vim.api.nvim_set_keymap("n", "<leader>zt", "<Cmd>ZkTags<CR>", lsp_map_opts)
      vim.api.nvim_set_keymap("n", "<leader>zf",
        "<Cmd>ZkNotes { sort = { 'modified' } }<CR>", lsp_map_opts)
      -- vim.api.nvim_set_keymap("n", "<leader>zf",
      --   "<Cmd>ZkNotes { sort = { 'modified' }, excludeHrefs = { '" .. zk_notebook_dir .. "/diary'} }<CR>", lsp_map_opts)
      vim.api.nvim_set_keymap("n", "<leader>zF",
        "<Cmd>ZkNotes { sort = { 'modified' }, excludeHrefs = { '" .. zk_notebook_dir .. "/diary'} }<CR>", lsp_map_opts)
      vim.api.nvim_set_keymap("v", "<leader>zf", ":'<,'>ZkMatch<CR>", lsp_map_opts)
      vim.api.nvim_set_keymap("n", "<leader>zw", "<CMD>ZkNew { dir = '" .. zk_notebook_dir .. "/diary' }<CR>", lsp_map_opts)
      vim.api.nvim_set_keymap(
        "n",
        "<leader>zz",
        "<CMD>ZkNotes { sort = { 'title' }, tags = { 'Index' } }<CR>",
        lsp_map_opts
      )
      vim.api.nvim_set_keymap(
        "n",
        "<leader>zd",
        "<CMD>ZkNotes { sort = { 'created' }, tags = { 'diary' } }<CR>",
        lsp_map_opts
      )
      vim.api.nvim_set_keymap(
        "n",
        "<leader>tl",
        "<CMD>ZkNotes { sort = { 'modified' }, tags = { 'Todo' } }<CR>",
        lsp_map_opts
      )
      vim.api.nvim_set_keymap(
        "n",
        "<leader>zt",
        "<CMD>ZkNotes { sort = { 'modified' }, tags = { 'Todo' } }<CR>",
        lsp_map_opts
      )

    end,
  }
}
