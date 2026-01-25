-- vai.nvim UI rendering with extmarks

local config = require("vai.config")

local M = {}

local ns_id = vim.api.nvim_create_namespace("vai")

--- Setup highlight groups
function M.setup_highlights()
	-- Label highlight: dark gray background with purple text to match theme
	vim.api.nvim_set_hl(0, "VaiLabel", {
		fg = "#c792ea",
		bg = "#000000",
		bold = true,
	})

	-- Dim highlight for non-target lines
	vim.api.nvim_set_hl(0, "VaiDim", {
		fg = "#555555",
	})
end

--- Clear all vai extmarks
function M.clear()
	local buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
end

--- Show group labels in the gutter
---@param groups table<string, { above: number[], below: number[] }>
function M.show_group_labels(groups)
	local buf = vim.api.nvim_get_current_buf()
	local hl = config.options.highlights.label

	for label, group in pairs(groups) do
		-- Show label on all lines in this group (above)
		for _, line in ipairs(group.above) do
			M.set_label(buf, line, label, hl)
		end
		-- Show label on all lines in this group (below)
		for _, line in ipairs(group.below) do
			M.set_label(buf, line, label, hl)
		end
	end
end

--- Show line labels after group is selected
--- Above: farthest gets 'a', closest gets last label (reversed)
--- Below: closest gets 'a', farthest gets last label (normal)
---@param group_lines { above: number[], below: number[] }
function M.show_line_labels(group_lines)
	local buf = vim.api.nvim_get_current_buf()
	local labels = config.get_labels(13)
	local hl = config.options.highlights.label

	-- Clear previous labels
	M.clear()

	-- Above lines: farthest gets first label, closest gets last
	-- group_lines.above[1] is closest to cursor, so we reverse the label assignment
	local above_count = #group_lines.above
	for i, line in ipairs(group_lines.above) do
		local label_idx = above_count - i + 1 -- reverse: closest gets last label
		if label_idx > #labels then
			break
		end
		M.set_label(buf, line, labels[label_idx], hl)
	end

	-- Below lines: closest gets first label, farthest gets last (normal order)
	for i, line in ipairs(group_lines.below) do
		if i > #labels then
			break
		end
		M.set_label(buf, line, labels[i], hl)
	end
end

--- Set a label on a specific line
---@param buf number
---@param line number 1-indexed line number
---@param label string
---@param hl string highlight group
function M.set_label(buf, line, label, hl)
	-- Ensure line is valid
	local line_count = vim.api.nvim_buf_line_count(buf)
	if line < 1 or line > line_count then
		return
	end

	-- Place label at start of line, overlaying content
	vim.api.nvim_buf_set_extmark(buf, ns_id, line - 1, 0, {
		virt_text = { { label, hl } },
		virt_text_pos = "overlay",
		priority = 1000,
	})
end

--- Dim all lines except the cursor line
function M.dim_buffer()
	local buf = vim.api.nvim_get_current_buf()
	local first_line = vim.fn.line("w0")
	local last_line = vim.fn.line("w$")
	local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
	local hl = config.options.highlights.dim

	for line = first_line, last_line do
		if line ~= cursor_line then
			local line_content = vim.api.nvim_buf_get_lines(buf, line - 1, line, false)[1]
			if line_content then
				vim.api.nvim_buf_set_extmark(buf, ns_id, line - 1, 0, {
					end_col = #line_content,
					hl_group = hl,
					priority = 100,
				})
			end
		end
	end
end

return M
