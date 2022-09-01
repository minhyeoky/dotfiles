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

require("lint").linters_by_ft = {
	markdown = { "vale" },
	python = { "pylint" },
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	callback = function()
		require("lint").try_lint()
	end,
})

-- By filetypes: https://github.com/mhartington/formatter.nvim/tree/master/lua/formatter/filetypes
require("formatter").setup({
	logging = true,
	log_level = vim.log.levels.WARN,
	filetype = {
		lua = {
			require("formatter.filetypes.lua").stylua,
		},
    python = {
			require("formatter.filetypes.python").black,
			require("formatter.filetypes.python").isort,
			require("formatter.filetypes.python").docformatter,
    },
    sh = {
			require("formatter.filetypes.sh").shfmt,
    },
    json = {
			require("formatter.filetypes.json").jq,
    },
		["*"] = {
			-- https://github.com/mhartington/formatter.nvim/issues/159#issuecomment-1173490890
			function()
				return { exe = "sed", args = { "-i", "''", "'s/[	 ]*$//'" } }
			end,
		},
	},
})

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
