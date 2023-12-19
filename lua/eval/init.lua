local M = {}

function M.eval(param)
	vim.cmd.normal("")

	local vstart = vim.fn.getpos("'<")
	local vend = vim.fn.getpos("'>")
	assert(vstart ~= nil)
	assert(vend ~= nil)

	local text = vim.api.nvim_buf_get_text(0, vstart[2] - 1, vstart[3] - 1, vend[2] - 1, vend[3], {})

	local result = {}
	local function on_either(_, data)
		if not data or #data < 1 or (#data == 1 and data[1] == "") then
			return
		end

		vim.list_extend(result, data)
	end
	local job_id = vim.fn.jobstart(param.fargs, {
		on_stdout = on_either,
		on_stderr = on_either,
		on_exit = function(_, code)
			if code ~= 0 then
				vim.notify("Job failed with code " .. tostring(code), vim.log.levels.ERROR)
			end
		end,
	})
	if job_id <= 0 then
		vim.notify("Failed to start job with command '" .. param.fargs .. "'", vim.log.levels.ERROR)
		return
	end

	vim.fn.chansend(job_id, text)
	vim.fn.chanclose(job_id, "stdin")
	vim.fn.jobwait({ job_id })

	vim.api.nvim_buf_set_text(0, vstart[2] - 1, vstart[3] - 1, vend[2] - 1, vend[3], result)
end

return M
