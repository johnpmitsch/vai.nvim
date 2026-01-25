-- vai.nvim jump logic and input handling
-- vai.nvim jump logic and input handling

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

--- Check if a character is a valid label
---@param char string
---@param valid_labels string[]
---@return boolean
local function is_valid_label(char, valid_labels)
	for _, label in ipairs(valid_labels) do
		if char == label then
			return true
		end
	end
	return false
end

--- Main entry point: start the jump sequence
function M.start()
	local config = require("vai.config")
	local labels = require("vai.labels")
	local ui = require("vai.ui")
	-- Build groups for visible lines
	local groups = labels.build_groups()

	-- Check if there are any lines to jump to
	local has_lines = false
	for _, group in pairs(groups) do
		if #group.above > 0 or #group.below > 0 then
			has_lines = true
			break
		end
	end

	if not has_lines then
		vim.notify("vai: no lines to jump to", vim.log.levels.WARN)
		return
	end

	-- Stage 1: Show group labels
	ui.dim_buffer()
	ui.show_group_labels(groups)
	vim.cmd("redraw")

	-- Get group selection
	local group_char = get_char()
	if not group_char then
		ui.clear()
		vim.cmd("redraw")
		return
	end

	-- Validate group selection
	local valid_groups = config.get_labels(13)
	if not is_valid_label(group_char, valid_groups) then
		ui.clear()
		vim.cmd("redraw")
		vim.notify('vai: invalid group "' .. group_char .. '"', vim.log.levels.WARN)
		return
	end

	-- Check if group has any lines
	local group = groups[group_char]
	if not group or (#group.above == 0 and #group.below == 0) then
		ui.clear()
		vim.cmd("redraw")
		vim.notify('vai: no lines in group "' .. group_char .. '"', vim.log.levels.WARN)
		return
	end

	-- Stage 2: Show line labels within the selected group
	ui.show_line_labels(group)
	vim.cmd("redraw")

	-- Get line selection
	local line_char = get_char()
	if not line_char then
		ui.clear()
		vim.cmd("redraw")
		return
	end

	-- Validate line selection
	local valid_lines = config.get_labels(13)
	if not is_valid_label(line_char, valid_lines) then
		ui.clear()
		vim.cmd("redraw")
		vim.notify('vai: invalid line "' .. line_char .. '"', vim.log.levels.WARN)
		return
	end

	-- Find the target line
	local target_line = M.resolve_line(group, line_char)
	if not target_line then
		ui.clear()
		vim.cmd("redraw")
		vim.notify("vai: line not found", vim.log.levels.WARN)
		return
	end

	-- Clear UI and jump
	ui.clear()
	vim.cmd("redraw")
	M.execute_jump(target_line)
end

--- Resolve a line character to an actual line number
--- Above: 'a' = farthest, last label = closest (reversed)
--- Below: 'a' = closest, last label = farthest (normal)
---@param group { above: number[], below: number[] }
---@param line_char string
---@return number|nil
function M.resolve_line(group, line_char)
	local config = require("vai.config")
	local line_labels = config.get_labels(13)

	-- Find the index of this label
	local label_idx = nil
	for i, label in ipairs(line_labels) do
		if label == line_char then
			label_idx = i
			break
		end
	end

	if not label_idx then
		return nil
	end

	-- Below: label index maps directly (a=1 → closest)
	if group.below[label_idx] then
		return group.below[label_idx]
	end

	-- Above: label index is reversed (a=1 → farthest, so we need to reverse)
	local above_count = #group.above
	local above_idx = above_count - label_idx + 1
	if above_idx >= 1 and group.above[above_idx] then
		return group.above[above_idx]
	end

	return nil
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
