-- disable LSP in a specific directory
local DIRS_LSP_DISABLED = {
  "qmk_firmware",
}

vim.defer_fn(function()
  local filepath = vim.fn.expand("%:p")

  for _, dir in ipairs(DIRS_LSP_DISABLED) do
    if filepath:match(dir) then
      vim.cmd("LspStop")
      break
    end
  end
end, 150)
