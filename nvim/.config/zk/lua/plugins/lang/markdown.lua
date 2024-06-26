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
    cmd = {
      "MarkdownPreviewToggle",
      "MarkdownPreview",
      "MarkdownPreviewStop",
    },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
    init = function()
      vim.g.mkdp_auto_close = 0  -- don't close the preview window when the source buffer is closed
    end,
  },

  {
    "ellisonleao/glow.nvim",
    config = function()
      require("glow").setup({
        border = "rounded",
      })
    end,
    cmd = { "Glow" },
    keys = {
      { "<leader>g", "<cmd>Glow<CR>" },
    },
  },
}
