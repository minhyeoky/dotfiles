vim.g.mapleader = ","

vim.keymap.set({ "v" }, "<C-c>", '"*y')

vim.keymap.set({ "n" }, "<leader>tn", ":tabnew<CR>", { silent = true })
vim.keymap.set({ "n" }, "<leader>tc", ":tabclose<CR>", { silent = true })
vim.keymap.set({ "n" }, "<leader>to", ":tabonly<CR>", { silent = true })
vim.keymap.set({ "n" }, "<leader>1", "1gt", { silent = true })
vim.keymap.set({ "n" }, "<leader>2", "2gt", { silent = true })
vim.keymap.set({ "n" }, "<leader>3", "3gt", { silent = true })
vim.keymap.set({ "n" }, "<leader>4", "4gt", { silent = true })
vim.keymap.set({ "n" }, "<leader>5", "5gt", { silent = true })
vim.keymap.set({ "n" }, "<leader>6", "6gt", { silent = true })
vim.keymap.set({ "n" }, "<leader>7", "7gt", { silent = true })
vim.keymap.set({ "n" }, "<leader>8", "8gt", { silent = true })
vim.keymap.set({ "n" }, "<leader>9", "9gt", { silent = true })
vim.keymap.set({ "n" }, "<leader>0", ":tablast<CR>", { silent = true })
