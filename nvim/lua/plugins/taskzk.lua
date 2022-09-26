local Path = require("plenary.path")
local Job = require("plenary.job")

local function link()
  local cur_buf_filename = vim.api.nvim_buf_get_name(0)
  local p = Path.new(cur_buf_filename)

  -- Check if current file is in ZK dir or not
  if p:parents()[1] == os.getenv("ZK_NOTEBOOK_DIR") then
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
        local paths = vim.split(p:absolute(), Path.path.sep)
        local filename = paths[#paths]
        local job_annotate = Job:new({ command = "task", args = { "annotate", id, "zk: " .. filename } })
        job_annotate:sync()
      end,
    })
  end
end

M = {
  link = link,
}

return M
