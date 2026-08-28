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
			-- Fall back to LSP formatting when no CLI formatter is on PATH,
			-- instead of doing nothing and warning.
			default_format_opts = { lsp_format = "fallback" },
			formatters_by_ft = {
				css = { "prettier" },
				html = { "prettier" },
				javascript = { "prettier" },
				javascriptreact = { "prettier" },
				json = { "prettier" },
				jsonc = { "prettier" },
				lua = { "stylua" },
				python = { "black", "ruff_fix", "ruff_organize_imports" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
			},
		},
	},
}
