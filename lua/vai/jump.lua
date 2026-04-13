-- vai.nvim jump logic and input handling

local config = require("vai.config")
local labels = require("vai.labels")
local ui = require("vai.ui")

local M = {}

--- Get a character from the user
---@return string|nil char, or nil if cancelled
local function get_char()
	local ok, char = pcall(vim.fn.getcharstr)
	if not ok then
		return nil
	end
	-- Check for escape (27 is ESC, also check for literal escape)
	if char == "\27" or char == "\x1b" then
		return nil
	end
	return char
end

--- Filter label_map to only labels starting with prefix
---@param label_map table<string, number>
---@param prefix string
---@return table<string, number>
local function filter_labels_by_prefix(label_map, prefix)
	local filtered = {}
	for label, line in pairs(label_map) do
		if label:sub(1, #prefix) == prefix then
			filtered[label] = line
		end
	end
	return filtered
end

--- Main entry point: start the jump sequence
function M.start()
	-- Build all labels
	local label_map = labels.build_labels()

	-- Check if there are any lines to jump to
	if vim.tbl_isempty(label_map) then
		vim.notify("vai: no lines to jump to", vim.log.levels.WARN)
		return
	end

	-- Show all labels
	ui.dim_buffer()
	ui.show_labels(label_map)
	vim.cmd("redraw")

	-- Get first character
	local char1 = get_char()
	if not char1 then
		ui.clear()
		vim.cmd("redraw")
		return
	end

	-- Filter to matching labels and preview them
	local matching = filter_labels_by_prefix(label_map, char1)
	if vim.tbl_isempty(matching) then
		ui.clear()
		vim.cmd("redraw")
		vim.notify('vai: no labels starting with "' .. char1 .. '"', vim.log.levels.WARN)
		return
	end

	-- Highlight all lines that match the first character
	for _, line in pairs(matching) do
		ui.show_preview(line)
	end
	vim.cmd("redraw")

	-- Get second character
	local char2 = get_char()
	if not char2 then
		ui.clear()
		vim.cmd("redraw")
		return
	end

	local label = char1 .. char2
	local target_line = label_map[label]

	ui.clear()
	vim.cmd("redraw")

	if not target_line then
		vim.notify('vai: invalid label "' .. label .. '"', vim.log.levels.WARN)
		return
	end

	M.execute_jump(target_line)
end

--- Execute the jump to target line
---@param target_line number
function M.execute_jump(target_line)
	-- Get current mode
	local mode = vim.fn.mode(true)

	-- Move cursor to target line, column 0 (first non-blank would be ^)
	vim.api.nvim_win_set_cursor(0, { target_line, 0 })

	-- For linewise operations, move to first non-blank
	if mode:match("[vVoO]") then
		vim.cmd("normal! ^")
	end
end

return M
