-- AUTHOR: Minhyeok Lee
-- TODO: Migrate to Packer.
vim.api.nvim_set_keymap("n", "<leader>S", "<cmd>Startify<cr>", { silent = true, noremap = true })

--------------------------------------------------------------------------------
-- trouble
--------------------------------------------------------------------------------
require("trouble").setup({
  mode = "document_diagnostics",
  auto_preview = false,
  auto_fold = true,
})
vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<cr>", { silent = true, noremap = true })
vim.keymap.set("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", { silent = true, noremap = true })
vim.keymap.set("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", { silent = true, noremap = true })
vim.keymap.set("n", "<leader>xl", "<cmd>TroubleToggle loclist<cr>", { silent = true, noremap = true })
vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", { silent = true, noremap = true })
vim.keymap.set("n", "gR", "<cmd>TroubleToggle lsp_references<cr>", { silent = true, noremap = true })

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
  signcolumn = false, -- Toggle with `:Gitsigns toggle_signs`
  numhl = true,       -- Toggle with `:Gitsigns toggle_numhl`
  linehl = false,     -- Toggle with `:Gitsigns toggle_linehl`
  word_diff = false,  -- Toggle with `:Gitsigns toggle_word_diff`
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
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, { expr = true })

    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, { expr = true })

    -- Actions
    map('n', '<leader>ds', gs.stage_hunk)
    map('n', '<leader>dr', gs.reset_hunk)
    map('v', '<leader>ds', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
    map('v', '<leader>dr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
    map('n', '<leader>du', gs.undo_stage_hunk)
    map('n', '<leader>dp', gs.preview_hunk)
    map('n', '<leader>db', function() gs.blame_line { full = true } end)
    map('n', '<leader>dd', gs.diffthis)

    -- Text object
    map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
})

--------------------------------------------------------------------------------
-- mason
--------------------------------------------------------------------------------
require("mason").setup()

require("mason-lspconfig").setup({
  ensure_installed = {
    "pyright@1.1.339",
  },
  automatic_installation = false,
})

--------------------------------------------------------------------------------
-- null-ls
-- NOTE: nvim --headless -c "MasonInstall codespell actionlint shellcheck hadolint stylua jq shfmt cbfmt" -c "qall"
--------------------------------------------------------------------------------
require("null-ls").setup({
  debug = false,
  sources = {
    require("null-ls").builtins.diagnostics.shellcheck,
    require("null-ls").builtins.formatting.jq,
    require("null-ls").builtins.formatting.black,
    require("null-ls").builtins.formatting.trim_newlines,
    require("null-ls").builtins.formatting.trim_whitespace,
  },
})

--------------------------------------------------------------------------------
-- nvim-treesitter
--------------------------------------------------------------------------------
require("nvim-treesitter.configs").setup({
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
    disable = function(_, buf)
      local max_filesize = 1024 * 1024 -- 1MiB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,
    additional_vim_regex_highlighting = false,
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
  -- "pylyzer",
  "ruff_lsp",
  -- "pylsp",
  "bashls",
  -- "jsonls",
  "lua_ls",
  "flutter-tools",
  "html",
  "jdtls",
  "tsserver",
  "dockerls",
  "cssls",
  "rust_analyzer",
  "clangd",

  "terraformls",
  "tflint",
  -- "marksman",
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
    { name = "nvim_lsp_signature_help" },
    {
      name = "buffer",
      option = {
        get_bufnrs = function()
          return vim.api.nvim_list_bufs()
        end,
      },
    },
    --{ name = "ultisnips" },
    --{ name = "jira" },
  }, {}),
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

local lsp_map_opts = { noremap = true, silent = true }
-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer

local on_attach = function(client, bufnr)
  -- Disable LSP's highlighting and use treesitter's instead.
  -- client.server_capabilities.semanticTokensProvider = nil

  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  vim.api.nvim_set_keymap("n", "<space>e", "<cmd>lua vim.diagnostic.open_float()<CR>", lsp_map_opts)
  vim.api.nvim_set_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", lsp_map_opts)
  vim.api.nvim_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", lsp_map_opts)
  vim.api.nvim_set_keymap("n", "<space>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", lsp_map_opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", lsp_map_opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", lsp_map_opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", lsp_map_opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", lsp_map_opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", lsp_map_opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", '"', "<cmd>lua vim.lsp.buf.signature_help()<CR>", lsp_map_opts)

  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
  vim.keymap.set('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", lsp_map_opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", lsp_map_opts)
  vim.api.nvim_buf_set_keymap(
    bufnr,
    "n",
    "<leader>f",
    "<cmd>lua vim.lsp.buf.format({ async = false })<CR>",
    lsp_map_opts
  )
end

for _, lsp in ipairs(SERVERS) do
  local config = {
    capabilities = cmp_nvim_lsp.default_capabilities(),
    on_attach = on_attach,
  }

  -- LSP specific settings ...
  if lsp == "lua_ls" then
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
        auto_open = false,    -- if true this will open the outline automatically when it is first populated
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
      unpack({ "requirements.txt" })
    )
    config["settings"] = {
      python = {
        analysis = {
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = "workspace",
        },
      },
    }
  end

  -- Setup
  lspconfig[lsp].setup(config)

  ::continue::
end

-------------------------------------------------------------------------------
-- zk
-------------------------------------------------------------------------------
local zk_notebook_dir = vim.env.ZK_NOTEBOOK_DIR

if zk_notebook_dir ~= nil then
  require("zk").setup({
    picker = "fzf",
    lsp = {
      auto_attach = {
        enabled = true,
      },
      config = {
        on_attach = on_attach,
      },
    },
  })

  vim.api.nvim_set_keymap("n", "<leader>zb", "<Cmd>ZkBacklinks<CR>", lsp_map_opts)
  vim.api.nvim_set_keymap("n", "<leader>zn", "<Cmd>ZkNew<CR>", lsp_map_opts)
  vim.api.nvim_set_keymap("n", "<leader>zt", "<Cmd>ZkTags<CR>", lsp_map_opts)
  vim.api.nvim_set_keymap("n", "<leader>zf",
    "<Cmd>ZkNotes { sort = { 'created' }, excludeHrefs = { '" .. zk_notebook_dir .. "/diary'} }<CR>", lsp_map_opts)
  vim.api.nvim_set_keymap("n", "<leader>zF",
    "<Cmd>ZkNotes { sort = { 'modified' }, excludeHrefs = { '" .. zk_notebook_dir .. "/diary'} }<CR>", lsp_map_opts)
  vim.api.nvim_set_keymap("v", "<leader>zf", ":'<,'>ZkMatch<CR>", lsp_map_opts)
  vim.api.nvim_set_keymap("n", "<leader>zw", "<CMD>ZkNew { dir = '" .. zk_notebook_dir .. "/diary' }<CR>", lsp_map_opts)
  vim.api.nvim_set_keymap(
    "n",
    "<leader>zz",
    "<CMD>ZkNotes { sort = { 'title' }, tags = { 'Index' } }<CR>",
    lsp_map_opts
  )
  vim.api.nvim_set_keymap(
    "n",
    "<leader>zd",
    "<CMD>ZkNotes { sort = { 'created' }, tags = { 'diary' } }<CR>",
    lsp_map_opts
  )
  vim.api.nvim_set_keymap("n", "<leader>td", "<CMD>edit " .. zk_notebook_dir .. "/todo.md<CR>", lsp_map_opts)
end

-------------------------------------------------------------------------------
-- ChatGPT
-------------------------------------------------------------------------------
require("chatgpt").setup({
  actions_paths = { os.getenv("DOTFILES_PATH") .. "/nvim/chatgpt/actions.json" },
})

vim.api.nvim_set_keymap("n", "<leader>cg", "<Cmd>ChatGPT<CR>", { silent = true })

-------------------------------------------------------------------------------
-- true-zen with twilight
-------------------------------------------------------------------------------
require("zen-mode").setup({
  window = {
    width = 120, -- colorcolumn & textwidth
    options = {
      signcolumn = "no",
      cursorcolumn = false,
      cursorline = false,
    },
  },
  plugins = {
    gitsigns = { enabled = true },
    tmux = { enabled = false },
    alacritty = { enabled = true },
    options = {
      enabled = true,
      ruler = false,
      showcmd = true,
      showmode = false,
    },
    twilight = { enabled = false },
  },
})

require("twilight").setup({
  expand = {
    "function",
    "method",
    "table",
    "if_statement",
    "import_statement",
  },
})

vim.api.nvim_set_keymap("n", "<leader>Z", "<CMD>ZenMode<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<leader>T", "<CMD>Twilight<CR>", { silent = true })

-------------------------------------------------------------------------------
-- harpoon
-------------------------------------------------------------------------------
vim.keymap.set("n", "<leader>a", require("harpoon.mark").add_file)
vim.keymap.set("n", "<leader>e", require("harpoon.ui").toggle_quick_menu)

vim.keymap.set("n", "<leader>1", function() require("harpoon.ui").nav_file(1) end)
vim.keymap.set("n", "<leader>2", function() require("harpoon.ui").nav_file(2) end)
vim.keymap.set("n", "<leader>3", function() require("harpoon.ui").nav_file(3) end)
vim.keymap.set("n", "<leader>4", function() require("harpoon.ui").nav_file(4) end)

-------------------------------------------------------------------------------
-- indent-blankline & virt-column
-------------------------------------------------------------------------------
require("ibl").setup({
  -- ['|', '¦', '┆', '┊']
  indent = { char = "┊" },
})
-- require("virt-column").setup()

-------------------------------------------------------------------------------
-- rest.nvim
-------------------------------------------------------------------------------
require("rest-nvim").setup({
  -- Open request results in a horizontal split
  result_split_horizontal = false,
  -- Keep the http file buffer above|left when split horizontal|vertical
  result_split_in_place = false,
  -- Skip SSL verification, useful for unknown certificates
  skip_ssl_verification = false,
  -- Encode URL before making request
  encode_url = true,
  -- Highlight request on run
  highlight = {
    enabled = true,
    timeout = 150,
  },
  result = {
    -- toggle showing URL, HTTP info, headers at top the of result window
    show_url = true,
    -- show the generated curl command in case you want to launch
    -- the same request via the terminal (can be verbose)
    show_curl_command = false,
    show_http_info = true,
    show_headers = true,
    -- executables or functions for formatting response body [optional]
    -- set them to false if you want to disable them
    formatters = {
      json = "jq",
      html = function(body)
        return vim.fn.system({"tidy", "-i", "-q", "-"}, body)
      end
    },
  },
  -- Jump to request line on run
  jump_to_request = false,
  env_file = '.env',
  custom_dynamic_variables = {},
  yank_dry_run = true,
})

vim.keymap.set("n", "<leader>rr", "<Plug>RestNvim<CR>", { silent = true })
vim.keymap.set("n", "<leader>rp", "<Plug>RestNvimPreview<CR>", { silent = true })
vim.keymap.set("n", "<leader>rl", "<Plug>RestNvimLast<CR>", { silent = true })

-------------------------------------------------------------------------------
-- rest.nvim
-------------------------------------------------------------------------------
require('gitlinker').setup()
