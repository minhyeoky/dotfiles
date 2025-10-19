return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        enabled = true,
      },
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              codeLens = {
                enable = true,
              },
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        },
      },
    },
    config = function(_, opts)
      -- enable lspconfig for opts.servers
      for server, config in pairs(opts.servers) do
        config["on_attach"] = function(client, _)
          -- enable inlay hints if available
          if client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable()
          end
        end
        require("lspconfig")[server].setup(config)
      end


      -- setup key mappings
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)

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
      ensure_installed = {},
    },
    config = true,
  },

  {
    "b0o/schemastore.nvim",
  },
}
