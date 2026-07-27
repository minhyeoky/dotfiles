-- Database interface: vim-dadbod (engine) + UI + nvim-cmp completion.
-- Connect with a single URL, e.g. :DB sqlite:/path/to.db "SELECT 1"
-- Browse with :DBUI. Connections added via :DBUIAddConnection persist outside
-- this repo (~/.local/share/db_ui/), so no personal DBs live in the config.
return {
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", cmd = "DB", lazy = true },
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    keys = {
      { "<leader>D", "<cmd>DBUIToggle<cr>", desc = "Database UI" },
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_win_position = "left"
      -- dadbod-completion is buffer-local; wire it into nvim-cmp per sql filetype.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function()
          local ok, cmp = pcall(require, "cmp")
          if ok then
            cmp.setup.buffer({
              sources = {
                { name = "vim-dadbod-completion" },
                { name = "buffer" },
              },
            })
          end
        end,
      })
    end,
  },
}
