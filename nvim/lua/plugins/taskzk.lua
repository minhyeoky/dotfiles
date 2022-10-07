local Path = require("plenary.path")
local Job = require("plenary.job")

local function _is_note()
  return Path.new(vim.api.nvim_buf_get_name(0)):parents()[1] == os.getenv("ZK_NOTEBOOK_DIR")
end

local function _get_note()
  local paths = vim.split(Path.new(vim.api.nvim_buf_get_name(0)):absolute(), Path.path.sep)
  return paths[#paths]
end

local function link()
  if not _is_note() then
    return
  end

  local job = Job:new({
    command = "task",
    args = { "status:pending", "export" },
  })
  job:sync()
  local entries = {}
  for _, value in ipairs(vim.json.decode(vim.fn.join(job:result()))) do
    -- Use fzf to select task
    table.insert(entries, "[" .. value.id .. "]" .. " " .. value.description)
  end
  vim.fn["fzf#run"]({
    source = entries,
    sink = function(e)
      local id = e:match("%d+")
      local job_annotate = Job:new({ command = "task", args = { "annotate", id, "zk: " .. _get_note() } })
      job_annotate:sync()
    end,
  })
end

M = {
  link = link,
}

return M
