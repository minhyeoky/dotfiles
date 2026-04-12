-- cc-edit: When Claude Code opens $EDITOR on Ctrl-G (tempfile matching
-- claude-prompt-*.md), open the last assistant response in a read-only split
-- beside the prompt draft.
--
-- Pairs with the SessionStart hook at:
--   my-plugins/hooks/scripts/cc-edit-context.sh
-- which records transcript_path to a TTY-keyed registry file.
--
-- Configure by calling setup with options, e.g.:
--   require('cc-edit').setup({ ratio = 0.7 })

local M = {}

M.config = {
  -- Width of the response pane as a fraction of total columns (0..1).
  ratio = 0.5,
}

local function current_tty()
  -- Walk up the process tree to find an ancestor with a real tty.
  -- Mirrors the logic in cc-edit-context.sh so both sides resolve the
  -- same registry key.
  local pid = vim.fn.getpid()
  while pid and pid ~= 0 and pid ~= 1 do
    local t = vim.fn.system('ps -o tty= -p ' .. pid):gsub('[%s/]', '')
    if t ~= '' and t ~= '??' then
      return t
    end
    local ppid = vim.fn.system('ps -o ppid= -p ' .. pid):gsub('%s', '')
    pid = tonumber(ppid)
  end
  return nil
end

local function registry_path(tty)
  local tmpdir = vim.env.TMPDIR or '/tmp'
  if not tmpdir:match('/$') then tmpdir = tmpdir .. '/' end
  return tmpdir .. 'cc-edit-context/' .. tty .. '.json'
end

local function load_context()
  -- Note: CLAUDECODE env is NOT propagated to the EDITOR child spawned by
  -- Ctrl-G (CC scrubs it via CLAUDE_CODE_SUBPROCESS_ENV_SCRUB). The combo of
  -- the claude-prompt-*.md autocmd pattern plus a registry hit is specific
  -- enough to avoid false positives.
  local tty = current_tty()
  if not tty then return nil end

  local reg = registry_path(tty)
  if vim.fn.filereadable(reg) == 0 then return nil end

  local raw = vim.fn.readfile(reg)[1]
  if not raw or raw == '' then return nil end
  local ok, ctx = pcall(vim.json.decode, raw)
  if not ok then return nil end
  return ctx
end

-- Extract the last assistant text block. Walks backward from EOF, returns
-- the last `text` block from the most recent `type:"assistant"` entry that
-- has one.
local function extract_last_response(transcript_path)
  if not transcript_path or vim.fn.filereadable(transcript_path) == 0 then
    return nil
  end
  local lines = vim.fn.readfile(transcript_path)
  for i = #lines, 1, -1 do
    local ok, e = pcall(vim.json.decode, lines[i])
    if ok and type(e) == 'table' and e.type == 'assistant'
       and type(e.message) == 'table'
       and type(e.message.content) == 'table' then
      local last_text
      for _, b in ipairs(e.message.content) do
        if type(b) == 'table' and b.type == 'text'
           and type(b.text) == 'string' and b.text ~= '' then
          last_text = b.text
        end
      end
      if last_text then return last_text end
    end
  end
  return nil
end

local function open_context_layout()
  local ctx = load_context()
  if not ctx then return end

  local text = extract_last_response(ctx.transcript_path)
  if not text then return end

  local prompt_win = vim.api.nvim_get_current_win()

  -- Create an empty vsplit on the far left, then populate its (new, unnamed)
  -- buffer with the response. Uses an in-memory scratch buffer — no file is
  -- written to disk, so concurrent CC sessions never share state (no swap
  -- collision, no undofile interleaving, no content races).
  vim.cmd('topleft vnew')
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].swapfile = false
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(text, '\n', { plain = true }))
  vim.bo[buf].filetype = 'markdown'
  vim.bo[buf].modifiable = false
  vim.bo[buf].readonly = true
  pcall(vim.api.nvim_buf_set_name, buf, 'cc-last-response')

  vim.cmd('vertical resize ' .. math.floor(vim.o.columns * M.config.ratio))

  if vim.api.nvim_win_is_valid(prompt_win) then
    vim.api.nvim_set_current_win(prompt_win)
  end
end

function M.setup(opts)
  if opts then
    M.config = vim.tbl_deep_extend('force', M.config, opts)
  end
  local group = vim.api.nvim_create_augroup('cc-edit', { clear = true })
  vim.api.nvim_create_autocmd('BufReadPost', {
    group = group,
    pattern = '*claude-prompt-*.md',
    callback = function()
      vim.schedule(open_context_layout)
    end,
  })
end

M.setup()
return M
