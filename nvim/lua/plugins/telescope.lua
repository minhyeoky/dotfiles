local telescope = require("telescope")
telescope.setup{
  defaults = {
    layout_strategy = 'vertical',
    mappings = {
      i = {
        ["<esc>"] = require('telescope.actions').close,
        ["<C-q>"] = require('telescope.actions').smart_send_to_qflist,
        ["<C-l>"] = require('telescope.actions').smart_send_to_loclist,
      }
    },
  }
}
