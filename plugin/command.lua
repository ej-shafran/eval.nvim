vim.api.nvim_create_user_command("Eval", require("eval").eval, {
	nargs = "*",
	range = true
})
