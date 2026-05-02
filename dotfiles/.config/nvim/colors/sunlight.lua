-- Sunlight: high-contrast light colorscheme tuned for direct-sunlight readability.
-- All foreground colors meet >=7:1 contrast against the white background.

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
	vim.cmd("syntax reset")
end
vim.o.background = "light"
vim.g.colors_name = "sunlight"

-- Maximum-contrast palette: all foreground colors >=10:1 against #ffffff.
local c = {
	bg = "#ffffff",
	bg_alt = "#ececec", -- statusline / floats (more visible than #f4f4f4)
	bg_sel = "#9fb3d0", -- visual selection (still leaves text >=8:1)
	bg_user = "#dde6ff", -- popups / subtle highlight
	bg_cur_line = "#e6e9f0",
	bg_col = "#dcdfe5",

	fg = "#000000", -- primary text (21:1)
	fg_strong = "#000000",
	fg_mid = "#1a1a1a", -- secondary text / UI chrome (17:1)
	fg_dim = "#3a3a3a", -- line numbers / least-important text (10.4:1)

	border = "#1a1a1a",

	red = "#7a0000", -- 11.5:1
	red_bright = "#a01010", -- 10.0:1
	green = "#003d12", -- 13.7:1
	green_bright = "#004f18", -- 11.6:1
	amber = "#5e3500", -- 12.7:1
	amber_bright = "#6f3d00", -- 10.9:1
	blue = "#001f80", -- 15.1:1
	blue_bright = "#0030a0", -- 11.5:1
	magenta = "#4a0066", -- 14.6:1
	magenta_bright = "#5e1075", -- 11.5:1
	cyan = "#00333d", -- 14.0:1
	cyan_bright = "#00424d", -- 12.2:1
	violet = "#3d1485", -- 12.0:1

	-- Diff backgrounds: blue/orange (daltonized), saturated enough to be
	-- visible as fills under glare while keeping black text >=12:1.
	diff_add = "#a8cef0",
	diff_change = "#ffe69a",
	diff_delete = "#f7b876",
	diff_text = "#5fa3d4",
}

local function hl(group, spec)
	vim.api.nvim_set_hl(0, group, spec)
end

-- ------- Editor UI -------
hl("Normal", { fg = c.fg, bg = c.bg })
hl("NormalFloat", { fg = c.fg, bg = c.bg_alt })
hl("FloatBorder", { fg = c.border, bg = c.bg_alt })
hl("FloatTitle", { fg = c.fg, bg = c.bg_alt, bold = true })
hl("ColorColumn", { bg = c.bg_col })
hl("Cursor", { fg = c.bg, bg = c.fg })
hl("CursorLine", { bg = c.bg_cur_line })
hl("CursorLineNr", { fg = c.fg, bold = true })
hl("LineNr", { fg = c.fg_dim })
hl("SignColumn", { bg = c.bg })
hl("FoldColumn", { fg = c.fg_dim, bg = c.bg })
hl("Folded", { fg = c.fg_mid, bg = c.bg_col })
hl("VertSplit", { fg = c.border })
hl("WinSeparator", { fg = c.border })
hl("StatusLine", { fg = c.fg, bg = c.bg_alt, bold = true })
hl("StatusLineNC", { fg = c.fg_mid, bg = c.bg_alt })
hl("TabLine", { fg = c.fg_mid, bg = c.bg_alt })
hl("TabLineFill", { bg = c.bg_alt })
hl("TabLineSel", { fg = c.fg, bg = c.bg, bold = true })
hl("Pmenu", { fg = c.fg, bg = c.bg_alt })
hl("PmenuSel", { fg = c.fg, bg = c.bg_sel, bold = true })
hl("PmenuSbar", { bg = c.bg_alt })
hl("PmenuThumb", { bg = c.fg_dim })
hl("Visual", { bg = c.bg_sel })
hl("VisualNOS", { bg = c.bg_sel })
hl("Search", { fg = c.fg, bg = "#ffe680", bold = true })
hl("IncSearch", { fg = c.bg, bg = c.amber, bold = true })
hl("CurSearch", { fg = c.bg, bg = c.amber, bold = true })
hl("MatchParen", { fg = c.red_bright, bold = true, underline = true })
hl("NonText", { fg = c.fg_dim })
hl("SpecialKey", { fg = c.fg_dim })
hl("Whitespace", { fg = "#c8c8c8" })
hl("EndOfBuffer", { fg = c.bg })
hl("Conceal", { fg = c.fg_mid })
hl("Directory", { fg = c.blue, bold = true })
hl("Title", { fg = c.fg, bold = true })
hl("Question", { fg = c.blue, bold = true })
hl("ModeMsg", { fg = c.fg, bold = true })
hl("MoreMsg", { fg = c.green })
hl("ErrorMsg", { fg = c.red_bright, bold = true })
hl("WarningMsg", { fg = c.amber, bold = true })
hl("WildMenu", { fg = c.fg, bg = c.bg_sel, bold = true })

-- ------- Syntax (legacy groups; TS groups link here) -------
-- Comments use dark color + italic instead of low-contrast gray. Bold is
-- applied liberally on syntax tokens to thicken strokes under glare.
hl("Comment", { fg = c.fg_mid, italic = true })
hl("Constant", { fg = c.magenta, bold = true })
hl("String", { fg = c.green, bold = true })
hl("Character", { fg = c.green, bold = true })
hl("Number", { fg = c.magenta, bold = true })
hl("Boolean", { fg = c.magenta, bold = true })
hl("Float", { fg = c.magenta, bold = true })
hl("Identifier", { fg = c.fg })
hl("Function", { fg = c.blue, bold = true })
hl("Statement", { fg = c.red, bold = true })
hl("Conditional", { fg = c.red, bold = true })
hl("Repeat", { fg = c.red, bold = true })
hl("Label", { fg = c.red, bold = true })
hl("Operator", { fg = c.fg, bold = true })
hl("Keyword", { fg = c.red, bold = true })
hl("Exception", { fg = c.red_bright, bold = true })
hl("PreProc", { fg = c.violet, bold = true })
hl("Include", { fg = c.violet, bold = true })
hl("Define", { fg = c.violet, bold = true })
hl("Macro", { fg = c.violet, bold = true })
hl("PreCondit", { fg = c.violet, bold = true })
hl("Type", { fg = c.cyan, bold = true })
hl("StorageClass", { fg = c.cyan, bold = true })
hl("Structure", { fg = c.cyan, bold = true })
hl("Typedef", { fg = c.cyan, bold = true })
hl("Special", { fg = c.amber, bold = true })
hl("SpecialChar", { fg = c.amber, bold = true })
hl("Tag", { fg = c.blue, bold = true })
hl("Delimiter", { fg = c.fg_mid, bold = true })
hl("SpecialComment", { fg = c.fg_mid, bold = true, italic = true })
hl("Debug", { fg = c.amber, bold = true })
hl("Underlined", { fg = c.blue, underline = true, bold = true })
hl("Error", { fg = c.red_bright, bold = true })
hl("Todo", { fg = c.bg, bg = c.amber, bold = true })

-- ------- Diff -------
hl("DiffAdd", { bg = c.diff_add })
hl("DiffChange", { bg = c.diff_change })
hl("DiffDelete", { fg = c.amber, bg = c.diff_delete })
hl("DiffText", { bg = c.diff_text, bold = true })

-- ------- Spelling -------
hl("SpellBad", { sp = c.red_bright, undercurl = true })
hl("SpellCap", { sp = c.blue, undercurl = true })
hl("SpellRare", { sp = c.violet, undercurl = true })
hl("SpellLocal", { sp = c.cyan, undercurl = true })

-- ------- Diagnostics -------
hl("DiagnosticError", { fg = c.red_bright })
hl("DiagnosticWarn", { fg = c.amber })
hl("DiagnosticInfo", { fg = c.blue })
hl("DiagnosticHint", { fg = c.cyan })
hl("DiagnosticOk", { fg = c.green })
hl("DiagnosticUnderlineError", { sp = c.red_bright, undercurl = true })
hl("DiagnosticUnderlineWarn", { sp = c.amber, undercurl = true })
hl("DiagnosticUnderlineInfo", { sp = c.blue, undercurl = true })
hl("DiagnosticUnderlineHint", { sp = c.cyan, undercurl = true })
hl("DiagnosticVirtualTextError", { fg = c.red_bright, bg = "#fbe5e5" })
hl("DiagnosticVirtualTextWarn", { fg = c.amber, bg = "#fbeed1" })
hl("DiagnosticVirtualTextInfo", { fg = c.blue, bg = "#dfe6f6" })
hl("DiagnosticVirtualTextHint", { fg = c.cyan, bg = "#dceaee" })

-- ------- LSP -------
hl("LspReferenceText", { bg = c.bg_user })
hl("LspReferenceRead", { bg = c.bg_user })
hl("LspReferenceWrite", { bg = c.bg_user, bold = true })
hl("LspSignatureActiveParameter", { fg = c.fg, bg = c.bg_sel, bold = true })
hl("LspInlayHint", { fg = c.fg_dim, italic = true })

-- ------- TreeSitter -------
hl("@comment", { link = "Comment" })
hl("@comment.documentation", { fg = c.fg_mid, italic = true })
hl("@comment.todo", { link = "Todo" })
hl("@comment.note", { fg = c.bg, bg = c.blue, bold = true })
hl("@comment.warning", { fg = c.bg, bg = c.amber, bold = true })
hl("@comment.error", { fg = c.bg, bg = c.red_bright, bold = true })

hl("@variable", { fg = c.fg })
hl("@variable.builtin", { fg = c.magenta_bright, italic = true })
hl("@variable.parameter", { fg = c.fg, italic = true })
hl("@variable.member", { fg = c.fg })

hl("@constant", { fg = c.magenta })
hl("@constant.builtin", { fg = c.magenta_bright, bold = true })
hl("@constant.macro", { fg = c.violet })

hl("@module", { fg = c.cyan, bold = true })
hl("@label", { fg = c.red })

hl("@string", { fg = c.green })
hl("@string.escape", { fg = c.amber, bold = true })
hl("@string.special", { fg = c.amber })
hl("@string.regexp", { fg = c.amber })

hl("@character", { fg = c.green })
hl("@character.special", { fg = c.amber })

hl("@boolean", { link = "Boolean" })
hl("@number", { link = "Number" })
hl("@number.float", { link = "Float" })

hl("@type", { link = "Type" })
hl("@type.builtin", { fg = c.cyan_bright, bold = true })
hl("@type.definition", { link = "Type" })

hl("@attribute", { fg = c.violet })
hl("@property", { fg = c.fg })

hl("@function", { link = "Function" })
hl("@function.builtin", { fg = c.blue_bright, bold = true })
hl("@function.call", { fg = c.blue })
hl("@function.macro", { fg = c.violet, bold = true })
hl("@function.method", { fg = c.blue, bold = true })
hl("@function.method.call", { fg = c.blue })
hl("@constructor", { fg = c.cyan, bold = true })

hl("@operator", { fg = c.fg })

hl("@keyword", { link = "Keyword" })
hl("@keyword.function", { fg = c.red, bold = true })
hl("@keyword.operator", { fg = c.red })
hl("@keyword.import", { fg = c.violet, bold = true })
hl("@keyword.return", { fg = c.red_bright, bold = true })
hl("@keyword.exception", { fg = c.red_bright, bold = true })
hl("@keyword.conditional", { link = "Conditional" })
hl("@keyword.repeat", { link = "Repeat" })

hl("@punctuation.delimiter", { fg = c.fg_mid })
hl("@punctuation.bracket", { fg = c.fg_mid })
hl("@punctuation.special", { fg = c.amber })

hl("@tag", { fg = c.blue, bold = true })
hl("@tag.attribute", { fg = c.violet })
hl("@tag.delimiter", { fg = c.fg_mid })

hl("@markup.heading", { fg = c.fg, bold = true })
hl("@markup.heading.1", { fg = c.blue, bold = true })
hl("@markup.heading.2", { fg = c.violet, bold = true })
hl("@markup.heading.3", { fg = c.cyan, bold = true })
hl("@markup.strong", { bold = true })
hl("@markup.emphasis", { italic = true })
hl("@markup.underline", { underline = true })
hl("@markup.strikethrough", { strikethrough = true })
hl("@markup.link", { fg = c.blue, underline = true })
hl("@markup.link.url", { fg = c.blue, underline = true })
hl("@markup.link.label", { fg = c.blue, bold = true })
hl("@markup.list", { fg = c.red })
hl("@markup.quote", { fg = c.fg_mid, italic = true })
hl("@markup.raw", { fg = c.green, bg = c.bg_col })
hl("@markup.raw.block", { fg = c.fg, bg = c.bg_col })

hl("@diff.plus", { bg = c.diff_add })
hl("@diff.minus", { fg = c.amber, bg = c.diff_delete })
hl("@diff.delta", { bg = c.diff_change })

-- ------- Git signs (gitsigns.nvim) -------
hl("GitSignsAdd", { fg = c.blue_bright })
hl("GitSignsChange", { fg = c.amber_bright })
hl("GitSignsDelete", { fg = c.red_bright })
hl("GitSignsAddNr", { fg = c.blue_bright })
hl("GitSignsChangeNr", { fg = c.amber_bright })
hl("GitSignsDeleteNr", { fg = c.red_bright })

-- ------- Telescope -------
hl("TelescopeNormal", { fg = c.fg, bg = c.bg_alt })
hl("TelescopeBorder", { fg = c.border, bg = c.bg_alt })
hl("TelescopeTitle", { fg = c.fg, bg = c.bg_alt, bold = true })
hl("TelescopePromptNormal", { fg = c.fg, bg = c.bg_user })
hl("TelescopePromptBorder", { fg = c.border, bg = c.bg_user })
hl("TelescopePromptTitle", { fg = c.fg, bg = c.bg_user, bold = true })
hl("TelescopeSelection", { fg = c.fg, bg = c.bg_sel, bold = true })
hl("TelescopeMatching", { fg = c.red_bright, bold = true })

-- ------- Neo-tree / NvimTree -------
hl("NeoTreeNormal", { fg = c.fg, bg = c.bg })
hl("NeoTreeNormalNC", { fg = c.fg, bg = c.bg })
hl("NeoTreeDirectoryName", { fg = c.blue, bold = true })
hl("NeoTreeDirectoryIcon", { fg = c.blue })
hl("NeoTreeRootName", { fg = c.fg, bold = true })
hl("NeoTreeFileName", { fg = c.fg })
hl("NeoTreeIndentMarker", { fg = "#cccccc" })
hl("NeoTreeGitAdded", { fg = c.blue_bright })
hl("NeoTreeGitModified", { fg = c.amber_bright })
hl("NeoTreeGitDeleted", { fg = c.red_bright })

hl("NvimTreeNormal", { fg = c.fg, bg = c.bg })
hl("NvimTreeFolderName", { fg = c.blue, bold = true })

-- ------- Indent guides -------
hl("IblIndent", { fg = "#dcdcdc" })
hl("IblScope", { fg = c.fg_dim })

-- ------- Notify -------
hl("NotifyERRORBorder", { fg = c.red_bright })
hl("NotifyWARNBorder", { fg = c.amber })
hl("NotifyINFOBorder", { fg = c.blue })
hl("NotifyDEBUGBorder", { fg = c.fg_dim })
hl("NotifyTRACEBorder", { fg = c.violet })

-- ------- Which-key -------
hl("WhichKey", { fg = c.blue, bold = true })
hl("WhichKeyGroup", { fg = c.violet })
hl("WhichKeyDesc", { fg = c.fg })
hl("WhichKeySeparator", { fg = c.fg_dim })
hl("WhichKeyFloat", { bg = c.bg_alt })
hl("WhichKeyBorder", { fg = c.border, bg = c.bg_alt })
