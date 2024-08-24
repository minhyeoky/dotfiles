return {
  {
    "stevearc/oil.nvim",
    opts = {
      default_file_explorer = false,  -- `false` to fix netrw `GBrowse`
    },
    config = true,
    keys = {
      {
        "<leader>fo",
        function()
          require("oil").open()
        end
      },
      {
        "<leader>fO",
        function()
          require("oil").open_float()
        end
      },
    },
  },

  {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v3.x",
      lazy = false,
      dependencies = {
        { "nvim-lua/plenary.nvim" },
        { "nvim-tree/nvim-web-devicons" },
        { "MunifTanjim/nui.nvim" },
        { 's1n7ax/nvim-window-picker' },

        -- sources
        -- { "prncss-xyz/neo-tree-zk.nvim" },
      },
      config = function()
        require("neo-tree").setup({
          window = {
            -- set "none" to remove existing mapping
            -- `window.mappings` for global mappings and this can be overridden
            mappings = {
              ["z"] = "none",
              ["za"] = "toggle_node",
              ["zC"] = "close_all_subnodes",
              ["zM"] = "close_all_nodes",
              ["zR"] = "expand_all_nodes",
            },
          },
          sources = {
            -- defaults
            "filesystem",
            "buffers",
            "git_status",

            -- external
            -- "zk",
          },

          -- zk = {},


        })
      end,
      keys = {
        {
          "<C-n>",
          function()
            require("neo-tree.command").execute({
              -- position = "float",
              reveal = true,
              toggle = true,
            })
          end,
        },
      },
  },
}
