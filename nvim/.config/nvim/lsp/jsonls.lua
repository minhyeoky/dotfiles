return {
  settings = {
    json = {
      format = {
        enable = true,
      },
      schemas = require("schemastore").json.schemas({
        -- No `select` → entire SchemaStore catalog active (filename auto-match).
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
