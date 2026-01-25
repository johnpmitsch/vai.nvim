-- vai.nvim label generation and math

local config = require("vai.config")

local M = {}

--- Get visible line range in current window
---@return number first_line, number last_line, number cursor_line
function M.get_visible_range()
	local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
	local first_line = vim.fn.line("w0")
	local last_line = vim.fn.line("w$")
	return first_line, last_line, cursor_line
end

--- Build group assignments for visible lines
--- Returns a table mapping group_label -> { above = {lines}, below = {lines} }
---@return table<string, { above: number[], below: number[] }>
function M.build_groups()
	local first_line, last_line, cursor_line = M.get_visible_range()
	local labels = config.get_labels(13)
	local lines_per_group = 13

	local groups = {}
	for _, label in ipairs(labels) do
		groups[label] = { above = {}, below = {} }
	end

	-- Assign lines above cursor
	local above_count = 0
	for line = cursor_line - 1, first_line, -1 do
		local group_idx = math.floor(above_count / lines_per_group) + 1
		if group_idx > #labels then
			break
		end
		local label = labels[group_idx]
		table.insert(groups[label].above, line)
		above_count = above_count + 1
	end

	-- Assign lines below cursor
	local below_count = 0
	for line = cursor_line + 1, last_line do
		local group_idx = math.floor(below_count / lines_per_group) + 1
		if group_idx > #labels then
			break
		end
		local label = labels[group_idx]
		table.insert(groups[label].below, line)
		below_count = below_count + 1
	end

	return groups
end

--- Build line labels for a specific group
--- Returns a table mapping line_label -> line_number
---@param group_lines { above: number[], below: number[] }
---@return table<string, number>
function M.build_line_labels(group_lines)
	local labels = config.get_labels(13)
	local line_map = {}

	-- Above lines: closest gets first label
	for i, line in ipairs(group_lines.above) do
		if i > #labels then
			break
		end
		line_map[labels[i]] = { line = line, direction = "above" }
	end

	-- Below lines: closest gets first label
	for i, line in ipairs(group_lines.below) do
		if i > #labels then
			break
		end
		line_map[labels[i]] = line_map[labels[i]] or {}
		-- If label already used for above, we need to handle collision
		if line_map[labels[i]].line then
			-- Store both - UI will show both
			line_map[labels[i]].below_line = line
		else
			line_map[labels[i]] = { line = line, direction = "below" }
		end
	end

	return line_map
end

--- Get all lines that should show a specific group label
---@param groups table<string, { above: number[], below: number[] }>
---@param group_label string
---@return number[] lines
function M.get_group_lines(groups, group_label)
	local group = groups[group_label]
	if not group then
		return {}
	end

	local lines = {}
	for _, line in ipairs(group.above) do
		table.insert(lines, line)
	end
	for _, line in ipairs(group.below) do
		table.insert(lines, line)
	end
	return lines
end

return M
