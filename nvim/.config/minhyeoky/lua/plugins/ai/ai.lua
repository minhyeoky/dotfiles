return {
  -- add chatgpt conversation
  {
    "robitx/gp.nvim",
    config = function()
      require("gp").setup({
        cmd_prefix = "",
        chat_dir = vim.env.ZK_NVIM_GP_CHAT_DIR,

        agents = {
          {
            name = "Max",
            chat = true,
            model = {
              model = "gpt-4-turbo", temperature = 0,
            },
            system_prompt = "**Persona Prompt for LLM Agent:**"
            .. "\n\n"
            .. "- **Language Proficiency:**\n"
            .. "  - Fluent in English and Korean.\n"
            .. "\n"
            .. "- **Communication Style:**\n"
            .. "  - Speaks with a sense of humor.\n"
            .. "  - Tends to provide educational insights.\n"
            .. "  - Prefers to discuss complex concepts at a high level.\n"
            .. "  - Talks extensively in conversations.\n"
            .. "\n"
            .. "- **Technical Background:**"
            .. "  - Skilled in Functional Programming (FP)."
            .. "  - Adheres to Domain-Driven Design (DDD) principles."
            .. "  - Has experience as a CTO in a tech startup."
            .. "  - Formerly researched in database lab."
            .. "\n"
            .. "- **Current Focus:**"
            .. "  - Working on redesigning a document ingestion pipeline."
            .. "\n"
            .. "- **Interpersonal Dynamics:**"
            .. "  - Collaborative, working closely with a colleague on the pipeline project."
            .. "\n"
            .. "- **Presentation of Ideas:**"
            .. "  - Explains technical processes in layman's terms where possible."
            .. "  - Keeps the conversation engaging and light-hearted.",
          },
        },
      })
    end,
    keys = {
      { "<leader>ain", "<cmd>ChatNew<cr>" },
      { "<leader>aif", "<cmd>ChatFinder<cr>" },
    },
  },

  -- add copilot
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      {
        "zbirenbaum/copilot-cmp",
        dependencies = {
          {
            "zbirenbaum/copilot.lua",
            event = "InsertEnter",
            cmd = "Copilot",
            opts = {},
            config = function(_, opts)
              require("copilot").setup(opts)
            end
          },
        },
        opts = {},
        config = function (_, opts)
          require("copilot_cmp").setup(opts)
        end
      },
    },
    opts = function (_, opts)
      table.insert(
        opts.sources,
        {
          name = "copilot",
          priority = 100,
          group_index = 1,
        }
      )
    end
  },
}
