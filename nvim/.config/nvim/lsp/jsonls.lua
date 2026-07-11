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
            description = "Claude Code settings",
            fileMatch = { "**/.claude/settings.json", "**/.claude/settings.local.json" },
            url = "https://json.schemastore.org/claude-code-settings.json",
            name = "claude-code-settings.json",
          },
        }
      }),
      validate = { enable = true },
    },
  },
}
