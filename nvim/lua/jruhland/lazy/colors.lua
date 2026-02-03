return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            require("catppuccin").setup({
                cmp = true,
                fidget = true,
                gitsigns = true,
                neotree = true,
                treesitter = true,
                telescope = true,
            })

            vim.cmd.colorscheme "catppuccin-mocha"
	    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
        end
    }
}
