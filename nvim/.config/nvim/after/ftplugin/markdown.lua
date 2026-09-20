-- 산문은 코드와 줄 개념이 다르다. 물리 줄 하나가 문단 하나이므로 화면에서 접고,
-- j/k 가 접힌 시각 줄을 따라가게 한다.
vim.opt_local.wrap = true
vim.opt_local.linebreak = true -- 단어 경계에서 접는다
vim.opt_local.breakindent = true -- 접힌 줄이 리스트 들여쓰기를 유지한다

-- count 가 붙으면 물리 줄로 되돌린다. relativenumber 가 세는 것이 물리 줄이라,
-- 12j 가 시각 줄을 타면 gutter 에 읽은 숫자와 착지점이 어긋난다.
local function vertical(key)
  return function()
    return vim.v.count == 0 and ("g" .. key) or key
  end
end

local opts = { buffer = true, silent = true, expr = true }
vim.keymap.set({ "n", "x" }, "j", vertical("j"), opts)
vim.keymap.set({ "n", "x" }, "k", vertical("k"), opts)

-- :unmap 은 인자 안의 bar 를 키 시퀀스로 먹으므로 exe 로 감싼다.
local undo = 'setlocal wrap< linebreak< breakindent<'
for _, m in ipairs({ "n", "x" }) do
  for _, k in ipairs({ "j", "k" }) do
    undo = undo .. ' | sil! exe "' .. m .. 'unmap <buffer> ' .. k .. '"'
  end
end

-- 저장 시 체크박스 통계 cookie 갱신 (org 의 before-save-hook 과 같은 자리).
local undo_cookies = require("markdown-cookies").attach(0)

vim.b.undo_ftplugin = (vim.b.undo_ftplugin and vim.b.undo_ftplugin .. " | " or "")
  .. undo
  .. " | "
  .. undo_cookies
