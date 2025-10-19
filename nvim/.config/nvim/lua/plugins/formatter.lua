return {
	{
		"stevearc/conform.nvim",
		lazy = true,
		keys = {
			{
				"<leader>cf",
				function()
					require("conform").format()
				end,
				desc = "Format code with Conform",
			},
		},
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "black", "ruff_fix", "ruff_organize_imports" },
			},
		},
	},
}
