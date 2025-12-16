return {
  settings = {
    json = {
      format = {
        enable = true,
      },
      schemas = require("schemastore").json.schemas({
        select = {
          "package.json",
        },
        extra = {
          {
            description = "Code Companion Workspace",
            fileMatch = { "codecompanion-workspace.json" },
            url = "https://raw.githubusercontent.com/olimorris/codecompanion.nvim/refs/heads/main/lua/codecompanion/workspace-schema.json",
            name = "codecompanion-workspace.json",
          },
        }
      }),
      validate = { enable = true },
    },
  },
}
