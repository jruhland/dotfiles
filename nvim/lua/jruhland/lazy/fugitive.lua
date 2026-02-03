vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

return {
    {
	    {
		     "tpope/vim-fugitive",
		     config = function()
			    vim.g.fugitive_git_executable = "git"
		     end
	    },
    }
}
