return {
  settings = {
    yaml = {
      -- Disable yamlls's built-in SchemaStore fetcher; delegate to
      -- schemastore.nvim so JSON/YAML share one source and don't double up.
      schemaStore = {
        enable = false,
        url = "",
      },
      schemas = require("schemastore").yaml.schemas({
        -- No `select` → entire SchemaStore catalog active (filename auto-match).
        extra = {},
      }),
    },
  },
}
