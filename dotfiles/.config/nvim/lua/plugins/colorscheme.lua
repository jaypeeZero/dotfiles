-- Use the high-contrast `sunlight` colorscheme when the OS is in light mode,
-- and tokyonight when dark. WezTerm/macOS pass the appearance through to nvim
-- via `&background`, so we just key off that and re-apply on OSAppearanceChanged.

local function apply()
	if vim.o.background == "light" then
		pcall(vim.cmd, "colorscheme sunlight")
	else
		pcall(vim.cmd, "colorscheme tokyonight")
	end
end

vim.api.nvim_create_autocmd("OptionSet", {
	pattern = "background",
	callback = apply,
})

return {
	-- Tell LazyVim which colorscheme to load on startup.
	{
		"LazyVim/LazyVim",
		opts = { colorscheme = function() apply() end },
	},
	-- Keep tokyonight available for dark mode.
	{ "folke/tokyonight.nvim", lazy = false, priority = 1000 },
}
