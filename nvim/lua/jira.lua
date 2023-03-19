local M = {}

local _issues = {}

function M.fetch_issues()
  local curl = require("plenary.curl")
  local res = curl.get({
    -- Parameterize JQL.
    url = "https://allganize2.atlassian.net/rest/api/2/search?jql=assignee%20in%20(5e121ce85361330daaead6f0)%20AND%20project%20in%20(ALL%2C%20ENG%2C%20API)%20AND%20issuetype%20in%20(standardIssueTypes()%2C%20subTaskIssueTypes()%2C%20Bug%2C%20Epic%2C%20Story%2C%20Task%2C%20Sub-task)%20AND%20status%20in%20(Hold%2C%20%22In%20Progress%22%2C%20%22In%20Review%22%2C%20QA%2C%20%22Selected%20for%20Development%22%2C%20Staging%2C%20%22To%20Do%22)%20ORDER%20BY%20status%20ASC%2C%20created%20DESC&maxResults=100",
    -- Parameterize email and token.
    auth = "mhlee@allganize.io:" .. os.getenv("AGN_JIRA_TOKEN"),
    headers = {
      accept = "application/json",
    },
  })

  _issues = {}
  for _, issue in ipairs(vim.fn.json_decode(res.body).issues) do
    table.insert(_issues, {
      key = issue.key,
      summary = issue.fields.summary,
    })
  end
end

vim.api.nvim_set_keymap(
  "n",
  "<leader>j",
  "<cmd>lua require('jira').fetch_issues()<CR>",
  { noremap = true, silent = true }
)

--------------------------------------------------------------------------------
-- nvim-cmp
--------------------------------------------------------------------------------
local source = {}

function source:is_available()
  return true
end

function source:get_position_encoding_kind()
  return "utf-8"
end

function source:get_keyword_pattern()
  return "%u+%-.*"
end

function source:get_trigger_characters()
  return { "-", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }
end

function source:complete(params, callback)
  local issue_prefix = params.context.cursor_line:match("%u+")
  local completions = {}

  for _, issue in ipairs(_issues) do
    if issue.key:match(string.format("^%s", issue_prefix)) then
      table.insert(completions, {
        label = issue.key .. " " .. issue.summary,
      })
    end
  end

  callback(completions)
end

function source:resolve(completion_item, callback)
  callback(completion_item)
end

function source:execute(completion_item, callback)
  callback(completion_item)
end

require("cmp").register_source("jira", source)

return M
