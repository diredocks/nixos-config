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

	-- Ensure lazy.nvim runs neo-tree's config/setup(opts) before executing commands
	require("lazy").load({ plugins = { "neo-tree.nvim" } })
	-- Resolve relative paths (e.g. `.`) to an absolute path so LazyVim's neo-tree opts scan properly
	local abs_dir = vim.uv.fs_realpath(dir) or vim.fn.fnamemodify(dir, ":p")
	require("neo-tree.command").execute({ action = "focus", dir = abs_dir })
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
			window = {
				mappings = {
					-- Disable <space> (toggle_node) so it doesn't conflict with <leader> keymaps
					["<space>"] = "none",
				},
			},
		},
	},
}
