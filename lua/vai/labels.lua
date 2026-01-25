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
--- Maps easiest combos to sweet spot distances, then fills outward
--- Returns a table mapping two-letter label -> line number
---@return table<string, number>
function M.build_labels()
	local first_line, last_line, cursor_line = M.get_visible_range()
	local combos = config.options.combos
	local sweet_start = config.options.sweet_spot_start or 6
	local sweet_end = config.options.sweet_spot_end or 15

	local result = {}
	local combo_idx = 1

	-- Count available lines in each direction
	local lines_above = cursor_line - first_line
	local lines_below = last_line - cursor_line

	-- Build line lists: reorder so sweet spot comes first
	-- Sweet spot (6-15), then close (1-5), then far (16+)
	local above_lines = {}
	local below_lines = {}

	-- Sweet spot lines first (6-15 from cursor)
	for dist = sweet_start, sweet_end do
		if cursor_line - dist >= first_line then
			table.insert(above_lines, cursor_line - dist)
		end
		if cursor_line + dist <= last_line then
			table.insert(below_lines, cursor_line + dist)
		end
	end

	-- Close lines (1-5 from cursor)
	for dist = 1, sweet_start - 1 do
		if cursor_line - dist >= first_line then
			table.insert(above_lines, cursor_line - dist)
		end
		if cursor_line + dist <= last_line then
			table.insert(below_lines, cursor_line + dist)
		end
	end

	-- Far lines (16+ from cursor)
	for dist = sweet_end + 1, math.max(lines_above, lines_below) do
		if cursor_line - dist >= first_line then
			table.insert(above_lines, cursor_line - dist)
		end
		if cursor_line + dist <= last_line then
			table.insert(below_lines, cursor_line + dist)
		end
	end

	-- Interleave above and below, assigning easiest combos first
	local above_idx = 1
	local below_idx = 1
	local assign_below = true -- start with below (more common to jump down)

	while combo_idx <= #combos and (above_idx <= #above_lines or below_idx <= #below_lines) do
		if assign_below and below_idx <= #below_lines then
			result[combos[combo_idx]] = below_lines[below_idx]
			below_idx = below_idx + 1
			combo_idx = combo_idx + 1
		elseif not assign_below and above_idx <= #above_lines then
			result[combos[combo_idx]] = above_lines[above_idx]
			above_idx = above_idx + 1
			combo_idx = combo_idx + 1
		elseif below_idx <= #below_lines then
			result[combos[combo_idx]] = below_lines[below_idx]
			below_idx = below_idx + 1
			combo_idx = combo_idx + 1
		elseif above_idx <= #above_lines then
			result[combos[combo_idx]] = above_lines[above_idx]
			above_idx = above_idx + 1
			combo_idx = combo_idx + 1
		end
		assign_below = not assign_below
	end

	return result
end

return M
