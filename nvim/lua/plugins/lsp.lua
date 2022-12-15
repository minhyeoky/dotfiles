local lspconfig = require("lspconfig")
local flutter_tools = require("flutter-tools")
local cmp_nvim_lsp = require("cmp_nvim_lsp")
local cmp = require("cmp")

local SERVERS = {
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
  "rust_analyzer",
  "marksman",
  "clangd",
  "zk",
}

-------------------------------------------------------------------------------
-- Setup nvim-cmp.
-------------------------------------------------------------------------------
cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
    end,
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  -- Default Mappings: https://github.com/hrsh7th/nvim-cmp/commit/93cf84f7deb2bdb640ffbb1d2f8d6d412a7aa558
  mapping = cmp.mapping.preset.insert({
    ["<CR>"] = cmp.mapping.confirm({ select = false }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "ultisnips" },
  }, {
    { name = "buffer" },
  }),
})

-- Set configuration for specific filetype.
cmp.setup.filetype("gitcommit", {
  sources = cmp.config.sources({
    { name = "buffer" },
  }),
  mapping = cmp.mapping.preset.cmdline({}),
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline("/", {
  sources = {
    { name = "buffer" },
  },
  mapping = cmp.mapping.preset.cmdline({}),
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
  sources = cmp.config.sources({
    { name = "path" },
  }, {
    { name = "cmdline" },
  }),
  mapping = cmp.mapping.preset.cmdline({}),
})

-------------------------------------------------------------------------------
-- Setup nvim-lsp.
-- Configurations: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
-------------------------------------------------------------------------------

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(_, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local opts = { noremap = true, silent = true }
  vim.api.nvim_set_keymap("n", "<space>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
  vim.api.nvim_set_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
  vim.api.nvim_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
  vim.api.nvim_set_keymap("n", "<space>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", '"', "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
  vim.api.nvim_buf_set_keymap(
    bufnr,
    "n",
    "<leader>wl",
    "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>",
    opts
  )
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>f", "<cmd>lua vim.lsp.buf.format({ async = false })<CR>", opts)
end

-------------------------------------------------------------------------------
-- Setup
-------------------------------------------------------------------------------
for _, lsp in ipairs(SERVERS) do
  local config = {
    capabilities = cmp_nvim_lsp.default_capabilities(),
    on_attach = on_attach,
  }

  -- LSP specific settings ...
  if lsp == "sumneko_lua" then
    config["settings"] = {
      Lua = {
        runtime = {
          -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
          version = "LuaJIT",
        },
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = { "vim" },
        },
        workspace = {
          -- Make the server aware of Neovim runtime files
          library = {
            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
            [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
          },
        },
      },
    }
  elseif lsp == "jdtls" then
    config["init_options"] = {
      extendedClientCapabilities = {
        progressReportProvider = true,
      },
    }
  elseif lsp == "flutter-tools" then
    local flutter_config = {
      lsp = config,
      outline = {
        open_cmd = "30vnew", -- command to use to open the outline buffer
        auto_open = true, -- if true this will open the outline automatically when it is first populated
      },
      dev_log = {
        enabled = true,
        open_cmd = "split",
      },
      ui = {
        border = "rounded",
        notification_style = "native",
      },
      widget_guides = {
        enabled = true,
      },
    }
    flutter_tools.setup(flutter_config)
    goto continue
  elseif lsp == "html" then
    config["capabilities"].textDocument.completion.completionItem.snippetSupport = true
  elseif lsp == "pyright" then
    config["root_dir"] = require("lspconfig.util").root_pattern(unpack({ "requirements.txt", "pyproject.toml", "setup.py",
      "setup.cfg" }))
  end

  -- Setup
  lspconfig[lsp].setup(config)

  ::continue::
end
