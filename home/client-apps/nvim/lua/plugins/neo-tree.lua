-- Open Snacks dashboard + Neo-tree sidebar when launching `nvim <dir>`
local function open_dir_workspace(dir)
	vim.cmd("enew")
	-- Drop initial directory buffers so bufferline won't show a ghost tab
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		local name = vim.api.nvim_buf_get_name(buf)
		if name ~= "" and vim.fn.isdirectory(name) == 1 then
			pcall(vim.api.nvim_buf_delete, buf, { force = true })
		end
	end

	-- Snacks.dashboard.setup() skips when argc > 0 without snacks_explorer
	if Snacks and Snacks.dashboard then
		vim.o.showtabline = 0
		Snacks.dashboard.open({ buf = 0, win = 0 })
	end

	require("neo-tree.command").execute({ action = "focus", dir = dir })
	vim.schedule(function()
		vim.o.showtabline = 0
		pcall(nvim_bufferline)
	end)
end

return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		init = function()
			vim.api.nvim_create_autocmd("VimEnter", {
				group = vim.api.nvim_create_augroup("Neotree_start_directory", { clear = true }),
				desc = "Open dashboard and Neo-tree when starting with a directory",
				once = true,
				callback = function()
					local arg = vim.fn.argc(-1) == 1 and vim.fn.argv(0) or ""
					if arg ~= "" and vim.fn.isdirectory(arg) == 1 then
						vim.schedule(function()
							open_dir_workspace(arg)
						end)
					end
				end,
			})
		end,
		opts = {
			filesystem = {
				-- Keep main window for dashboard instead of letting netrw/neo-tree take over
				hijack_netrw_behavior = "disabled",
			},
		},
	},
}
