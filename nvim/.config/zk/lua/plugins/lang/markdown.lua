return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- ensure that markdown and markdown_inline are always installed
      vim.list_extend(opts.ensure_installed, { "markdown", "markdown_inline" })
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "markdown", "markdown_inline" })
      end
    end,
  },

  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
  },

  --{
  --  "neovim/nvim-lspconfig",
  --  config = function()
  --    local lspconfig = require("lspconfig")
  --    lspconfig.marksman.setup({})
  --  end,
  --},
}
