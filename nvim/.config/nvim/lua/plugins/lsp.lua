return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- setup key mappings
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          -- enable inlay hints if available
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
          end

          -- Helper to toggle inlay hints
          local function toggle_inlay_hints()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          end

          -- Helper to toggle diagnostics
          local function toggle_diagnostics()
            vim.diagnostic.enable(not vim.diagnostic.is_enabled())
          end

          -- Buffer local mappings.
          -- See `:help vim.lsp.*` for documentation on any of the below functions
          local lsp_opts = { buffer = ev.buf }
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, lsp_opts)
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, lsp_opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, lsp_opts)
          vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, lsp_opts)
          vim.keymap.set('n', ']d', vim.diagnostic.goto_next, lsp_opts)
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, lsp_opts)
          vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, lsp_opts)
          vim.keymap.set('n', '<leader>ci', vim.lsp.buf.incoming_calls, lsp_opts)
          vim.keymap.set('n', '<leader>co', vim.lsp.buf.outgoing_calls, lsp_opts)
          vim.keymap.set('n', '<leader>ti', toggle_inlay_hints, lsp_opts)
          vim.keymap.set('n', '<leader>td', toggle_diagnostics, lsp_opts)
        end,
      })
    end
  },

  {
    "williamboman/mason.nvim",
    config = true,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {
        "bashls",
        "dockerls",
        "graphql",
        "html",
        "jsonls",
        "lua_ls",
        "pyright",
        "ruff",
        "rust_analyzer",
      },
    },
    config = true,
  },

  {
    "b0o/schemastore.nvim",
  },
}
