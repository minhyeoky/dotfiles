-- AUTHOR: Minhyeok Lee
-- TODO: Migrate to Packer.

--------------------------------------------------------------------------------
-- gitsigns
--------------------------------------------------------------------------------
require("gitsigns").setup({
  signs = {
    add = { hl = "GitSignsAdd", text = "│", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
    change = { hl = "GitSignsChange", text = "│", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
    delete = { hl = "GitSignsDelete", text = "_", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
    topdelete = { hl = "GitSignsDelete", text = "‾", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
    changedelete = { hl = "GitSignsChange", text = "~", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
  },
  signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
  numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
  linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
  watch_gitdir = {
    interval = 1000,
    follow_files = true,
  },
  attach_to_untracked = true,
  current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = "eol", -- "eol" | "overlay" | "right_align"
    delay = 10,
    ignore_whitespace = false,
  },
  current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
  sign_priority = 6,
  update_debounce = 10,
  status_formatter = nil, -- Use default
  max_file_length = 40000,
  preview_config = {
    -- Options passed to nvim_open_win
    border = "single",
    style = "minimal",
    relative = "cursor",
    row = 0,
    col = 1,
  },
  yadm = {
    enable = false,
  },
})

--------------------------------------------------------------------------------
-- tokyonight
--------------------------------------------------------------------------------
require("tokyonight").setup({
  style = "night",
  transparent = true,
  dim_inactive = true,
  lualine_bold = true,
})
vim.api.nvim_cmd({
  cmd = "colorscheme",
  args = { "tokyonight" },
}, {})

--------------------------------------------------------------------------------
-- mason
--------------------------------------------------------------------------------
require("mason").setup()

require("mason-lspconfig").setup({
  ensure_installed = {
    "pyright",
    "bashls",
    "jsonls",
    "sumneko_lua",
    "html",
    "jdtls",
    "tsserver",
    "dockerls",
    "cssls",
  },
  automatic_installation = true,
})

--------------------------------------------------------------------------------
-- null-ls
-- NOTE: nvim --headless -c "MasonInstall codespell actionlint shellcheck hadolint stylua jq shfmt cbfmt" -c "qall"
--------------------------------------------------------------------------------
require("null-ls").setup({
  sources = {
    -- require("null-ls").builtins.diagnostics.actionlint,
    -- require("null-ls").builtins.diagnostics.codespell,
    -- require("null-ls").builtins.diagnostics.pylint,
    require("null-ls").builtins.diagnostics.shellcheck,
    -- require("null-ls").builtins.diagnostics.eslint,
    -- require("null-ls").builtins.diagnostics.gitlint,
    -- require("null-ls").builtins.diagnostics.hadolint,
    -- require("null-ls").builtins.diagnostics.jsonlint,
    -- require("null-ls").builtins.diagnostics.misspell,

    require("null-ls").builtins.formatting.stylua,
    -- require("null-ls").builtins.formatting.black,
    -- require("null-ls").builtins.formatting.isort,
    require("null-ls").builtins.formatting.jq,
    -- require("null-ls").builtins.formatting.shfmt,
    -- require("null-ls").builtins.formatting.yamlfmt,
    require("null-ls").builtins.formatting.prettier,
    -- require("null-ls").builtins.formatting.cbfmt,
    require("null-ls").builtins.formatting.trim_newlines,
    require("null-ls").builtins.formatting.trim_whitespace,

    require("null-ls").builtins.code_actions.gitsigns,
    -- require("null-ls").builtins.code_actions.shellcheck,
    -- require("null-ls").builtins.code_actions.proselint,
    -- require("null-ls").builtins.code_actions.refactoring,
    -- require("null-ls").builtins.completion.tags,
  },
})

require("zk").setup({
  picker = "fzf",
  lsp = {
    auto_attach = {
      enabled = false,
    },
  },
})
local opts = { noremap = true, silent = false }

vim.api.nvim_set_keymap("n", "<leader>zn", "<Cmd>ZkNew<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader>zt", "<Cmd>ZkTags<CR>", opts)
vim.api.nvim_set_keymap(
  "n",
  "<leader>zf",
  "<Cmd>ZkNotes { sort = { 'modified' }, excludeHrefs = { 'private' } }<CR>",
  opts
)
vim.api.nvim_set_keymap("n", "<leader>zF", "<Cmd>ZkNotes { sort = { 'modified' } }<CR>", opts)
vim.api.nvim_set_keymap("v", "<leader>zf", ":'<,'>ZkMatch<CR>", opts)
vim.api.nvim_create_user_command("ZkFiles", ":call fzf#vim#files($ZK_NOTEBOOK_DIR,<bang>0)", { bang = true })
vim.api.nvim_create_user_command("ZkLink", ":lua require('plugins.taskzk').link()", {})
vim.api.nvim_create_user_command("ZkReferences", ":lua require('plugins.taskzk').references()", {})
vim.api.nvim_create_user_command("ZkTodos", ":lua require('plugins.taskzk').find_todos_by_tag()", {})

--------------------------------------------------------------------------------
-- nvim-treesitter
--------------------------------------------------------------------------------
require("nvim-treesitter.configs").setup({
  highlight = {
    enable = true,
    disable = function(_, buf)
      local max_filesize = 1024 * 1024 -- 1MiB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,
    additional_vim_regex_highlighting = {},
  },
  incremental_selection = {
    enable = true,
  },
  textobjects = {
    enable = true,
  },
})

--------------------------------------------------------------------------------
-- headlines.nvim
--------------------------------------------------------------------------------
vim.cmd([[highlight Orange guifg=#D19A66 gui=bold]])

require("headlines").setup({
  markdown = {
    dash_highlight = "Orange",
    dash_string = "—",
    quote_highlight = "Orange",
    quote_string = "┃",
    fat_headlines = false,
    -- fat_headline_upper_string = "▃",
    -- fat_headline_lower_string = "▀",
  },
})

--------------------------------------------------------------------------------
-- nvim-lspconfig
--------------------------------------------------------------------------------
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
  "clangd",
  "zk",
  -- "grammarly",
}

-------------------------------------------------------------------------------
-- nvim-cmp
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
    { name = "orgmode" },
  }),
  formatting = {
    format = require("lspkind").cmp_format({
      mode = "symbol_text",
      before = function(entry, vim_item)
        vim_item.menu = ({
          nvim_lsp = "[LSP]",
          buffer = "[BUF]",
          ultisnips = "[US]",
        })[entry.source.name]
        return vim_item
      end,
    }),
  },
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
    config["root_dir"] = require("lspconfig.util").root_pattern(
      unpack({ "requirements.txt", "pyproject.toml", "setup.py", "setup.cfg" })
    )
  end

  -- Setup
  lspconfig[lsp].setup(config)

  ::continue::
end
