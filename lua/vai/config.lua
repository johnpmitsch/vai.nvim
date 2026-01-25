-- vai.nvim configuration

local M = {}

M.defaults = {
	trigger = "\\",
	labels = {
		"a",
		"s",
		"d",
		"f",
		"g",
		"h",
		"j",
		"k",
		"l",
		"q",
		"w",
		"e",
		"r",
		"t",
		"y",
		"u",
		"i",
		"o",
		"p",
		"z",
		"x",
		"c",
		"v",
		"b",
		"n",
		"m",
	},
	highlights = {
		label = "VaiLabel",
		dim = "VaiDim",
	},
}

M.options = {}

--- Merge user options with defaults
---@param opts? table
function M.setup(opts)
	M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
end

--- Get the first n labels (used for groups and lines)
---@param n? number defaults to 13
---@return string[]
function M.get_labels(n)
	n = n or 13
	local result = {}
	for i = 1, math.min(n, #M.options.labels) do
		result[i] = M.options.labels[i]
	end
	return result
end

return M
