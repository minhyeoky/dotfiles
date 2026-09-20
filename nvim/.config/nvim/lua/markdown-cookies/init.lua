-- org-mode 의 statistics cookie 를 마크다운으로 옮긴 것.
-- 줄 끝 [n/m] 을 하위 체크박스 집계로 갱신하고, cookie 가 없는데 체크박스
-- 자식이 생긴 줄에는 붙이고, 자식이 사라진 줄에서는 뗀다.
--
-- org 와 갈리는 지점 둘:
--  * [x] 를 [X] 로 정규화하지 않는다. org 는 대문자만 세지만 마크다운·Obsidian
--    은 소문자가 표준이라, 세는 쪽에서 대소문자를 무시한다.
--  * fenced code block 안을 건너뛴다. org 의 블록 구분자(#+begin_src)는 헤딩
--    정규식에 안 걸리지만 마크다운에서는 `# comment` 가 헤딩처럼 보인다.

local M = {}

-- 집계 cookie 로 인정하는 상한. 이 위는 연도·날짜·쪽수 표기로 본다
-- (`[2024/2025]`). 체크리스트가 세 자리 항목을 갖는 경우는 없다고 본 것이고,
-- 이 선 덕분에 그런 표기가 저장 때마다 지워지지 않는다.
local MAX_COUNT = 99

local COOKIE = "%s*%[%d%d?/%d%d?%]%s*$"
local PERCENT = "%s*%[%d+%%%]%s*$"
local CHECKBOX = "^%s*[-*+]%s+%[([ xX%-])%]"
local HEADING = "^#+%s"
local FENCE = "^%s*([`~][`~][`~]+)"

local function indent_of(line, tabstop)
  local lead = line:match("^%s*")
  local width = 0
  for ch in lead:gmatch(".") do
    if ch == "\t" then
      width = width + tabstop - (width % tabstop)
    else
      width = width + 1
    end
  end
  return width
end

-- fence 안의 줄을 표시한다. 여는 구분자와 같은 문자·같은 길이 이상만 닫는다.
local function fenced_lines(lines)
  local inside, open = {}, nil
  for i, line in ipairs(lines) do
    local marker = line:match(FENCE)
    if open then
      inside[i] = true
      if marker and marker:sub(1, 1) == open:sub(1, 1) and #marker >= #open then
        open = nil
      end
    elseif marker then
      open, inside[i] = marker, true
    end
  end
  return inside
end

-- scope 안에서 가장 얕은 체크박스 줄들만 직속 자식으로 센다.
local function tally(ctx, from, to)
  local shallowest
  for i = from, to do
    if not ctx.fenced[i] and ctx.lines[i]:match(CHECKBOX) then
      local ind = indent_of(ctx.lines[i], ctx.tabstop)
      if not shallowest or ind < shallowest then
        shallowest = ind
      end
    end
  end
  if not shallowest then
    return nil
  end
  local done, total = 0, 0
  for i = from, to do
    if not ctx.fenced[i] then
      local mark = ctx.lines[i]:match(CHECKBOX)
      if mark and indent_of(ctx.lines[i], ctx.tabstop) == shallowest then
        total = total + 1
        if mark:lower() == "x" then
          done = done + 1
        end
      end
    end
  end
  if total > MAX_COUNT then
    return nil
  end
  return done, total
end

-- 헤딩의 직속 본문: 다음 헤딩 직전까지 (하위 헤딩은 제 몫을 따로 진다).
local function heading_scope(ctx, i)
  for j = i + 1, #ctx.lines do
    if not ctx.fenced[j] and ctx.lines[j]:match(HEADING) then
      return i + 1, j - 1
    end
  end
  return i + 1, #ctx.lines
end

-- 체크박스 항목의 자식: 들여쓰기가 더 깊은 동안. 빈 줄은 끊지 않는다.
local function item_scope(ctx, i)
  local base = indent_of(ctx.lines[i], ctx.tabstop)
  local last = i
  for j = i + 1, #ctx.lines do
    local line = ctx.lines[j]
    if line:match("^%s*$") then
      -- 계속 훑는다
    elseif ctx.fenced[j] then
      last = j
    elseif line:match(HEADING) or indent_of(line, ctx.tabstop) <= base then
      break
    else
      last = j
    end
  end
  return i + 1, last
end

local function set_cookie(line, done, total)
  local stripped, hits = line:gsub(COOKIE, "")
  local pct
  stripped, pct = stripped:gsub(PERCENT, "")
  -- cookie 도 없고 붙일 것도 없으면 줄을 건드리지 않는다. 마크다운에서 줄 끝
  -- 공백 두 칸은 hard line break 라, 무관한 줄의 공백을 정리하면 뜻이 바뀐다.
  if not done and hits + pct == 0 then
    return line
  end
  stripped = stripped:gsub("%s+$", "")
  if done then
    return stripped .. (" [%d/%d]"):format(done, total)
  end
  return stripped
end

function M.update(bufnr)
  bufnr = (bufnr == nil or bufnr == 0) and vim.api.nvim_get_current_buf() or bufnr
  if not vim.bo[bufnr].modifiable then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local ctx = {
    lines = lines,
    fenced = fenced_lines(lines),
    tabstop = vim.bo[bufnr].tabstop,
  }
  local changed = {}

  for i, line in ipairs(lines) do
    if not ctx.fenced[i] then
      local from, to
      if line:match(HEADING) then
        from, to = heading_scope(ctx, i)
      elseif line:match(CHECKBOX) then
        from, to = item_scope(ctx, i)
      end

      if from then
        local updated = set_cookie(line, tally(ctx, from, to))
        if updated ~= line then
          changed[i] = updated
        end
      end
    end
  end

  -- 바뀐 줄만 되쓴다. 버퍼 전체를 갈아치우면 커서와 undo 가 튄다.
  for i, text in pairs(changed) do
    vim.api.nvim_buf_set_lines(bufnr, i - 1, i, false, { text })
  end
end

-- ft 가 바뀌면 이 autocmd 도 같이 걷힌다. 버퍼 로컬 autocmd 는 filetype 전환에
-- 안 딸려가므로 undo_ftplugin 이 지워줘야 한다.
function M.attach(bufnr)
  bufnr = (bufnr == nil or bufnr == 0) and vim.api.nvim_get_current_buf() or bufnr
  local name = "MarkdownCookies" .. bufnr
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup(name, { clear = true }),
    buffer = bufnr,
    desc = "Update markdown checkbox statistics cookies",
    callback = function(ev)
      M.update(ev.buf)
    end,
  })
  return ('sil! lua pcall(vim.api.nvim_del_augroup_by_name, "%s")'):format(name)
end

return M
