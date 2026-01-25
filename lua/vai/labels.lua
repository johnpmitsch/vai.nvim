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

--- Build line labels for all visible lines
--- Returns a table mapping two-letter label -> line number
---@return table<string, number>
function M.build_labels()
	local first_line, last_line, cursor_line = M.get_visible_range()
	local labels = config.options.labels
	local group_labels = {}
	local line_labels_above = {}
	local line_labels_below = {}

	-- First 13 labels for groups
	for i = 1, 13 do
		if labels[i] then
			group_labels[i] = labels[i]
		end
	end

	-- Split 26 labels: first 13 for above, last 13 for below
	for i = 1, 13 do
		if labels[i] then
			line_labels_above[i] = labels[i]
		end
	end
	for i = 14, 26 do
		if labels[i] then
			line_labels_below[i - 13] = labels[i]
		end
	end

	local result = {}
	local lines_per_group = 13

	-- Build labels for lines above cursor
	local above_idx = 0
	for line = cursor_line - 1, first_line, -1 do
		above_idx = above_idx + 1
		local group_num = math.ceil(above_idx / lines_per_group)
		local line_in_group = ((above_idx - 1) % lines_per_group) + 1

		if group_num > #group_labels or line_in_group > #line_labels_above then
			break
		end

		-- For above: closest line gets last label in group (r), farthest gets first (a)
		local reversed_line_idx = lines_per_group - line_in_group + 1
		if reversed_line_idx <= #line_labels_above then
			local label = group_labels[group_num] .. line_labels_above[reversed_line_idx]
			result[label] = line
		end
	end

	-- Build labels for lines below cursor
	local below_idx = 0
	for line = cursor_line + 1, last_line do
		below_idx = below_idx + 1
		local group_num = math.ceil(below_idx / lines_per_group)
		local line_in_group = ((below_idx - 1) % lines_per_group) + 1

		if group_num > #group_labels or line_in_group > #line_labels_below then
			break
		end

		local label = group_labels[group_num] .. line_labels_below[line_in_group]
		result[label] = line
	end

	return result
end

return M
