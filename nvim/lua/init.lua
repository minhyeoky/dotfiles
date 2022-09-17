require("tokyonight").setup({
  style = "night",
  transparent = true,
  dim_inactive = true,
  lualine_bold = true,
})
vim.api.nvim_cmd({
  cmd = "colorscheme",
  args = { "tokyonight" },
}, {})

require("mason").setup()

require("mason-lspconfig").setup({
  ensure_installed = {
    "pyright",
    "bashls",
    "jsonls",
    "sumneko_lua",
    "flutter-tools",
    "html",
    "jdtls",
    "tsserver",
    "dockerls",
    "cssls",
  },
  automatic_installation = true,
})

-- Install
-- nvim --headless -c "MasonInstall codespell actionlint shellcheck hadolint stylua jq shfmt cbfmt" -c "qall"
require("null-ls").setup({
  sources = {
    require("null-ls").builtins.diagnostics.actionlint,
    require("null-ls").builtins.diagnostics.codespell,
    -- require("null-ls").builtins.diagnostics.pylint,
    require("null-ls").builtins.diagnostics.shellcheck,
    require("null-ls").builtins.diagnostics.eslint,
    require("null-ls").builtins.diagnostics.gitlint,
    require("null-ls").builtins.diagnostics.hadolint,
    -- require("null-ls").builtins.diagnostics.jsonlint,
    -- require("null-ls").builtins.diagnostics.misspell,

    require("null-ls").builtins.formatting.stylua,
    require("null-ls").builtins.formatting.black,
    require("null-ls").builtins.formatting.isort,
    require("null-ls").builtins.formatting.jq,
    require("null-ls").builtins.formatting.shfmt,
    require("null-ls").builtins.formatting.yamlfmt,
    require("null-ls").builtins.formatting.prettier,
    require("null-ls").builtins.formatting.cbfmt,
    require("null-ls").builtins.formatting.trim_newlines,
    require("null-ls").builtins.formatting.trim_whitespace,

    require("null-ls").builtins.code_actions.gitsigns,
    require("null-ls").builtins.code_actions.shellcheck,
    require("null-ls").builtins.code_actions.proselint,
    require("null-ls").builtins.code_actions.refactoring,
    require("null-ls").builtins.completion.tags,
  },
})

-- vim.api.nvim_create_autocmd({ "BufWritePre" }, {
--   pattern = { "*" },
--   callback = function()
--     vim.lsp.buf.format({ async = false })
--   end,
-- })

require("zk").setup({
  picker = "fzf",
})
local opts = { noremap = true, silent = false }

vim.api.nvim_set_keymap("n", "<leader>zn", "<Cmd>ZkNew { title = vim.fn.input('Title: ') }<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader>zo", "<Cmd>ZkNotes { sort = { 'modified' } }<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader>zt", "<Cmd>ZkTags<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader>zf", "<Cmd>ZkNotes { sort = { 'modified' } }<CR>", opts)
vim.api.nvim_set_keymap("v", "<leader>zf", ":'<,'>ZkMatch<CR>", opts)
vim.api.nvim_create_user_command("ZkFiles", ":call fzf#vim#files($ZK_NOTEBOOK_DIR,<bang>0)", { bang = true })
