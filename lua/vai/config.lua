-- vai.nvim configuration
local M = {}

local default_labels = {
	"a",
	"s",
	"d",
	"f",
	"g",
	"j",
	"k",
	"l", -- home row (8)
	"w",
	"e",
	"r",
	"t",
	"y",
	"u",
	"i",
	"o", -- top row (8)
	"c",
	"v",
	"n", -- bottom row (3)
}

-- Build combo list ordered by ease of typing
-- Doubles first (easiest), then fan out by label order
local function build_combo_list(labels)
	labels = labels or default_labels
	local combos = {}
	local used = {}

	-- Tier 1: Double letters (easiest to type)
	for _, l in ipairs(labels) do
		local combo = l .. l
		table.insert(combos, combo)
		used[combo] = true
	end

	-- Tier 2: Fan out by label order
	-- For each first letter (in priority order), add all second letters (in priority order)
	for _, c1 in ipairs(labels) do
		for _, c2 in ipairs(labels) do
			local combo = c1 .. c2
			if not used[combo] then
				table.insert(combos, combo)
				used[combo] = true
			end
		end
	end

	return combos
end

M.defaults = {
	trigger = "\\",
	labels = default_labels,
	-- Pre-built combo list ordered by typing ease
	combos = build_combo_list(default_labels),
	-- Sweet spot: where double letters should land (lines from cursor)
	sweet_spot_start = 6,
	sweet_spot_end = 15,
	highlights = {
		dim = "VaiDim",
	},
}

M.options = {}

--- Merge user options with defaults
---@param opts? table
function M.setup(opts)
	M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
	-- Rebuild combos if labels changed
	if opts and opts.labels then
		M.options.combos = build_combo_list(opts.labels)
	end
end

return M
