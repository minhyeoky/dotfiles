local MCP_HUB_CONFIG_PATH = vim.env.MCP_HUB_CONFIG_PATH

return {
  {
    "ravitemer/mcphub.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",  -- Required for Job and HTTP requests
    },
    build = "npm install -g mcp-hub@latest",
    config = function()
        require("mcphub").setup({
            -- Required options
            port = 3000,  -- Port for MCP Hub server
            config = vim.fn.expand(MCP_HUB_CONFIG_PATH),  -- Absolute path to config file

            -- Optional options
            on_ready = function(hub)
                -- Called when hub is ready
            end,
            on_error = function(err)
                -- Called on errors
            end,
            log = {
                level = vim.log.levels.WARN,
                to_file = false,
                file_path = nil,
                prefix = "MCPHub"
            },
        })
    end
  }
}
