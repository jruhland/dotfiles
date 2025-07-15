return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    lazy = false,
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        window = {
          position = "right",
          width = 32,
          mappings = {
            ["<C-b>"] = "close_window",
          },
        },
        filesystem = {
          hijack_netrw_behavior = "open_current",
          filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = true,
          },
          follow_current_file = {
            enabled = true,
            leave_dirs_open = false,
          },
        },
      })
      vim.keymap.set("n", "<C-b>", ":Neotree toggle<CR>", { noremap = true, silent = true })
    end,
  },
}
