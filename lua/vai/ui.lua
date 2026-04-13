-- vai.nvim UI rendering with extmarks

local config = require("vai.config")

local M = {}

local ns_id = vim.api.nvim_create_namespace("vai")
local preview_ns_id = vim.api.nvim_create_namespace("vai_preview")

-- Bright pastel colors for label rotation
local pastel_colors = {
	"#ff6b6b", -- coral red
	"#ffa06b", -- peach
	"#ffd93d", -- yellow
	"#c9f76f", -- lime
	"#6bcf7f", -- mint green
	"#4ecdc4", -- teal
	"#45b7d1", -- sky blue
	"#6b9fff", -- cornflower
	"#a06bff", -- purple
	"#d16bff", -- magenta
	"#ff6bd1", -- pink
	"#ff6b9f", -- rose
	"#ff8a6b", -- salmon
	"#ffb86b", -- orange
	"#ffe66b", -- golden
	"#b8ff6b", -- chartreuse
	"#6bff8a", -- spring green
	"#6bffcc", -- aquamarine
	"#6be0ff", -- cyan
	"#6bb8ff", -- dodger blue
	"#8a6bff", -- violet
	"#c46bff", -- orchid
	"#ff6be0", -- hot pink
	"#ff6bb8", -- carnation
	"#ff7b6b", -- tomato
	"#ffcc6b", -- gold
}

--- Setup highlight groups
function M.setup_highlights()
	-- Create a highlight group for each color
	for i, color in ipairs(pastel_colors) do
		vim.api.nvim_set_hl(0, "VaiLabel" .. i, {
			fg = color,
			bg = "#1a1a1a",
			bold = true,
		})
	end

	-- Dim highlight for non-target lines
	vim.api.nvim_set_hl(0, "VaiDim", {
		fg = "#555555",
	})

	-- Preview highlight for target line
	vim.api.nvim_set_hl(0, "VaiPreview", {
		bg = "#3a3a00", -- subtle yellow background
	})
end

--- Clear all vai extmarks
function M.clear()
	local buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
	vim.api.nvim_buf_clear_namespace(buf, preview_ns_id, 0, -1)
end

--- Clear only preview highlight
function M.clear_preview()
	local buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_clear_namespace(buf, preview_ns_id, 0, -1)
end

--- Get the indentation level of a line (number of leading whitespace chars)
---@param buf number
---@param line number 1-indexed
---@return number indent column position after indentation
local function get_indent_col(buf, line)
	local line_content = vim.api.nvim_buf_get_lines(buf, line - 1, line, false)[1]
	if not line_content then
		return 0
	end

	local indent = line_content:match("^%s*")
	return indent and #indent or 0
end

--- Show all labels on their lines
---@param label_map table<string, number> mapping of label -> line number
function M.show_labels(label_map)
	local buf = vim.api.nvim_get_current_buf()
	local labels_list = config.options.labels

	for label, line in pairs(label_map) do
		-- Get the second character to determine color (rotate within group)
		local second_char = label:sub(2, 2)
		local color_idx = 1
		for i, l in ipairs(labels_list) do
			if l == second_char then
				color_idx = ((i - 1) % #pastel_colors) + 1
				break
			end
		end

		local hl = "VaiLabel" .. color_idx
		M.set_label(buf, line, label, hl)
	end
end

--- Set a label on a specific line (at column 0)
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

--- Highlight a line as preview target
---@param line number 1-indexed line number
function M.show_preview(line)
	local buf = vim.api.nvim_get_current_buf()
	local line_count = vim.api.nvim_buf_line_count(buf)
	if line < 1 or line > line_count then
		return
	end

	-- Use line_hl_group to highlight the entire line
	vim.api.nvim_buf_set_extmark(buf, preview_ns_id, line - 1, 0, {
		line_hl_group = "VaiPreview",
		priority = 50,
	})
end

--- Dim all lines except the cursor line
function M.dim_buffer()
	local buf = vim.api.nvim_get_current_buf()
	local first_line = vim.fn.line("w0")
	local last_line = vim.fn.line("w$")
	local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
	local hl = "VaiDim"

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
