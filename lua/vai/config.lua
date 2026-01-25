-- vai.nvim configuration

local M = {}

local letters = {
	"a",
	"s",
	"d",
	"f",
	"g",
	"j",
	"k",
	"l", -- home row (9)
	"w",
	"e",
	"r",
	"t",
	"y",
	"u",
	"i",
	"o", -- top row easy (8)
	"c",
	"v",
	"n", -- bottom row easy (3)
}

-- Build combo list ordered by ease of typing
local function build_combo_list()
	local combos = {}

	-- Tier S: Double letters (easiest)
	local doubles = {
		"ff",
		"jj",
		"dd",
		"kk",
		"ss",
		"ll",
		"aa",
		"gg",
		"ee",
		"ii",
		"rr",
		"uu",
		"ww",
		"oo",
		"tt",
		"yy",
		"cc",
		"vv",
		"nn",
	}
	for _, combo in ipairs(doubles) do
		table.insert(combos, combo)
	end

	-- Tier A: Same-hand rolls (adjacent fingers, very fast)
	local rolls = {
		-- Left hand rolls
		"as",
		"sa",
		"sd",
		"ds",
		"df",
		"fd",
		"fg",
		"gf",
		"we",
		"ew",
		"er",
		"er",
		"rt",
		"tr",
		"cv",
		"vc",
		-- Right hand rolls
		"jk",
		"kj",
		"kl",
		"lk",
		"yu",
		"uy",
		"ui",
		"iu",
		"io",
		"oi",
	}
	for _, combo in ipairs(rolls) do
		table.insert(combos, combo)
	end

	-- Tier B: Same-hand non-adjacent (still easy, one hand)
	local same_hand = {
		-- Left hand
		"af",
		"fa",
		"ag",
		"ga",
		"sf",
		"fs",
		"sg",
		"gs",
		"dg",
		"gd",
		"wr",
		"rw",
		"wt",
		"tw",
		"et",
		"te",
		-- Right hand
		"jl",
		"lj",
		"yi",
		"iy",
		"yo",
		"oy",
		"uo",
		"ou",
	}
	for _, combo in ipairs(same_hand) do
		table.insert(combos, combo)
	end

	-- Tier C: Cross-hand easy (index/middle fingers)
	local cross_easy = {
		"fj",
		"jf",
		"fk",
		"kf",
		"dj",
		"jd",
		"dk",
		"kd",
		"gj",
		"jg",
		"ru",
		"ur",
		"ri",
		"ir",
		"eu",
		"ue",
		"ei",
		"ie",
		"ty",
		"yt",
		"tu",
		"ut",
		"ry",
		"yr",
	}
	for _, combo in ipairs(cross_easy) do
		table.insert(combos, combo)
	end

	-- Tier D: Fill remaining combos (all other combinations)
	local used = {}
	for _, combo in ipairs(combos) do
		used[combo] = true
	end

	for _, c1 in ipairs(letters) do
		for _, c2 in ipairs(letters) do
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
	labels = letters,
	-- Pre-built combo list ordered by typing ease
	combos = build_combo_list(),
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
		M.options.combos = build_combo_list()
	end
end

return M
