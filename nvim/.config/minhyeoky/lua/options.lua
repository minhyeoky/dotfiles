vim.opt.fileencoding = "utf-8"
vim.opt.number = true -- show line numbers
vim.opt.relativenumber = true -- show relative line numbers

vim.opt.foldmethod = "indent"
vim.opt.shiftwidth = 2     -- number of spaces to use for each step of (auto)indent
vim.opt.foldlevel = 99
vim.opt.confirm = true     -- confirm to save changes before existing modified buffer
vim.opt.smartindent = true -- insert indents automatically
vim.opt.expandtab = true   -- use spaces instead of tabs
vim.opt.tabstop = 2        -- number of spaces that a <Tab> in the file counts for
vim.opt.autowriteall = true  -- automatically write the file when switching buffers
vim.opt.conceallevel = 0  -- show concealable text
vim.opt.termguicolors = true  -- enable 24-bit RGB color in the TUI

vim.g.markdown_recommended_style = 0 -- disable markdown recommended style; like shiftwidth
vim.g.python3_host_prog = vim.env.NVIM_PYTHON3_HOST_PROG
