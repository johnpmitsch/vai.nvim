-- vai.nvim - Line jumping without numbers
-- Jump to any visible line with 3 keystrokes: trigger + group + line

local config = require("vai.config")
local jump = require("vai.jump")

local M = {}

--- Setup vai.nvim with optional configuration
---@param opts? table Configuration options
function M.setup(opts)
	config.setup(opts)

	-- Create highlight groups
	local ui = require("vai.ui")
	ui.setup_highlights()

	-- Set up keymaps
	local trigger = config.options.trigger
	vim.keymap.set({ "n", "x", "o" }, trigger, function()
		jump.start()
	end, { desc = "vai: jump to line" })
end

--- Start a jump (can be called directly)
function M.jump()
	jump.start()
end

return M
