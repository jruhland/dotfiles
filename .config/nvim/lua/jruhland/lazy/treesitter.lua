return {
	{
		{
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate",
			config = function()
				require('nvim-treesitter.configs').setup({
					ensure_installed = { "lua", "vim", "typescript", "javascript", "rust", "jsdoc", "go", "bash" },

					sync_install = false,
					auto_install = true,
					indent = { enable = true },
					highlight = { enable = true, additional_vim_regex_highlighting = false },
				})
			end
		}
	},
}
