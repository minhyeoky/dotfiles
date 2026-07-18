-- git 키맵은 leader(",") 아래 <leader>g* 로 통일한다. which-key 그룹라벨(whichkey.lua)이
-- ,g 팝업에서 +diff/+history/+stage/+review 로 갈라 보여줘 암기 대신 탐색으로 찾게 한다.

-- base 브랜치 해석: origin/HEAD 로컬 심볼릭 ref(오프라인) → 알려진 후보 프로브 → 로컬 → 실패.
-- set-head -a(네트워크)는 쓰지 않는다. 개인 GitHub=main / 회사 GitLab=master·develop 자동 대응.
local function git_base()
  local head = vim.fn.systemlist({ "git", "symbolic-ref", "--short", "refs/remotes/origin/HEAD" })
  if vim.v.shell_error == 0 and head[1] and head[1] ~= "" then
    return head[1]
  end
  for _, cand in ipairs({ "origin/main", "origin/master", "origin/develop", "main", "master" }) do
    vim.fn.system({ "git", "rev-parse", "--verify", "--quiet", cand })
    if vim.v.shell_error == 0 then
      return cand
    end
  end
  return nil
end

-- base 를 %s 로 끼운 리비전 표현으로 Diffview 를 연다. base 못 찾으면 알리고 중단(추측 금지).
local function diffview_base(spec)
  local base = git_base()
  if not base then
    vim.notify("git: base 브랜치를 찾을 수 없음 (origin/HEAD 미설정)", vim.log.levels.ERROR)
    return
  end
  vim.cmd("DiffviewOpen " .. string.format(spec, base))
end

-- push 할 커밋(base..HEAD)만 히스토리로. trunk 워크플로의 "올릴 커밋 검수".
local function push_log()
  local base = git_base()
  if not base then
    vim.notify("git: base 브랜치를 찾을 수 없음 (origin/HEAD 미설정)", vim.log.levels.ERROR)
    return
  end
  vim.cmd("DiffviewFileHistory --range=" .. base .. "..HEAD")
end

return {
  {
    "tpope/vim-fugitive",
    lazy = false,
    keys = {
      {
        "<leader>gg",
        "<cmd>tab Git<cr>",
        desc = "Git status",
      },
      {
        "<leader>gds",
        "<cmd>tab Git diff --staged<cr>",
        desc = "Diff staged (index vs HEAD)",
      },
    },
  },

  {
    "tpope/vim-rhubarb",
    dependencies = {
      { "tpope/vim-fugitive" },
    },
    lazy = false,
  },

  {
    "lewis6991/gitsigns.nvim",
    event = "BufRead",
    opts = {
      numhl = true,
      linehl = false,
      signcolumn = false,
      word_diff = false,

      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
        delay = 10,
        ignore_whitespace = false,
        virt_text_priority = 100,
      },
    },
    config = true,
    keys = {
      {
        "<leader>gss",
        function()
          require("gitsigns").stage_hunk()
        end,
        desc = "Stage hunk",
      },
      {
        "<leader>gsp",
        function()
          require("gitsigns").preview_hunk()
        end,
        desc = "Preview hunk",
      },
      {
        "<leader>gsr",
        function()
          require("gitsigns").reset_hunk()
        end,
        desc = "Reset hunk",
      },
      {
        "<leader>gsu",
        function()
          require("gitsigns").undo_stage_hunk()
        end,
        desc = "Undo stage hunk",
      },
      {
        "<leader>gsw",
        function()
          require("gitsigns").toggle_word_diff()
        end,
        desc = "Toggle word diff highlighting",
      },
      {
        "<leader>gsi",
        function()
          require("gitsigns").preview_hunk_inline()
        end,
        desc = "Preview hunk inline",
      },
      {
        "[c",
        function()
          require("gitsigns").prev_hunk()
        end,
        desc = "Previous hunk",
      },
      {
        "]c",
        function()
          require("gitsigns").next_hunk()
        end,
        desc = "Next hunk",
      },
    },
  },

  {
    "ruifm/gitlinker.nvim",
    dependencies =  { "nvim-lua/plenary.nvim" },
    config = function()
      require("gitlinker").setup({
        opts = {
          -- callback for what to do with the url
          action_callback = require("gitlinker.actions").copy_to_clipboard,

          print_url = false,
        },
      })
    end,
  },

  {
    "dlyongemallo/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewFileHistory",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewRefresh",
    },
    config = function()
      require("diffview").setup({
        hooks = {
          diff_buf_read = function()
            vim.opt_local.number = true
            vim.opt_local.relativenumber = false
          end,
        },
      })
    end,
    keys = {
      -- +diff : 코드 상태(스냅샷) 비교
      {
        "<leader>gdd",
        "<cmd>DiffviewOpen<cr>",
        desc = "Diff working tree vs HEAD",
      },
      {
        "<leader>gdc",
        "<cmd>DiffviewOpen HEAD~1<cr>",
        desc = "Diff vs previous commit (HEAD~1)",
      },
      {
        "<leader>gdb",
        function()
          diffview_base("%s...HEAD")
        end,
        desc = "Diff base...HEAD (순수 작업량, three-dot)",
      },
      {
        "<leader>gdB",
        function()
          diffview_base("%s")
        end,
        desc = "Diff vs base (base 최신, two-dot)",
      },
      {
        "<leader>gdy",
        function()
          local clipboard_content = vim.fn.getreg('+')
          local temp_file = vim.fn.tempname()
          vim.fn.writefile(vim.split(clipboard_content, '\n'), temp_file)
          vim.cmd('DiffviewOpen ' .. temp_file)
        end,
        mode = "n",
        desc = "Compare clipboard with current file",
      },
      {
        "<leader>gdy",
        function()
          local clipboard_content = vim.fn.getreg('+')
          local temp_file = vim.fn.tempname()
          vim.fn.writefile(vim.split(clipboard_content, '\n'), temp_file)

          -- Get visual selection
          local start_pos = vim.fn.getpos("'<")
          local end_pos = vim.fn.getpos("'>")
          local lines = vim.fn.getline(start_pos[2], end_pos[2])

          -- Create temp file with selection
          local selection_file = vim.fn.tempname()
          vim.fn.writefile(lines, selection_file)

          vim.cmd('DiffviewOpen ' .. selection_file .. ' ' .. temp_file)
        end,
        mode = "v",
        desc = "Compare clipboard with selection",
      },
      -- +history : 커밋 로그(집합) 추적
      {
        "<leader>ghh",
        "<cmd>DiffviewFileHistory<cr>",
        desc = "Trace repository history",
      },
      {
        "<leader>ghf",
        "<cmd>DiffviewFileHistory %<cr>",
        desc = "Trace current file history",
      },
      {
        "<leader>ghl",
        "<cmd>DiffviewFileHistory %<cr>",
        mode = "n",
        desc = "Trace current line history",
      },
      {
        "<leader>ghl",
        ":<C-u>'<,'>DiffviewFileHistory<cr>",
        mode = "v",
        desc = "Trace selection history",
      },
      {
        "<leader>ghp",
        push_log,
        desc = "Push preview log (base..HEAD)",
      },
    },
  },

  {
    "pwntester/octo.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "ibhagwan/fzf-lua",
      "nvim-tree/nvim-web-devicons",
    },
    cmd = "Octo",
    opts = {
      picker = "fzf-lua",
    },
    keys = {
      {
        "<leader>grr",
        "<cmd>Octo pr list<cr>",
        desc = "GitHub: PR list",
      },
      {
        "<leader>gri",
        "<cmd>Octo issue list<cr>",
        desc = "GitHub: issue list",
      },
      {
        "<leader>grv",
        "<cmd>Octo review start<cr>",
        desc = "GitHub: start PR review",
      },
    },
  },

  {
    "harrisoncramer/gitlab.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "dlyongemallo/diffview.nvim",
    },
    -- auth via shell env: GITLAB_TOKEN + GITLAB_URL (never committed here)
    build = function()
      require("gitlab.server").build(true)
    end,
    config = function()
      require("gitlab").setup()
    end,
    keys = {
      {
        "<leader>grm",
        function()
          require("gitlab").choose_merge_request()
        end,
        desc = "GitLab: choose merge request",
      },
      {
        "<leader>grR",
        function()
          require("gitlab").review()
        end,
        desc = "GitLab: review current MR",
      },
    },
  },

  {
    "shumphrey/fugitive-gitlab.vim",
    dependencies = { "tpope/vim-fugitive" },
    lazy = false,
    init = function()
      -- :GBrowse for GitLab remotes; domain comes from env, not this repo
      local gitlab_url = vim.env.GITLAB_URL
      if gitlab_url and gitlab_url ~= "" then
        vim.g.fugitive_gitlab_domains = { gitlab_url }
      end
    end,
  },
}
