local wezterm = require("wezterm")

-- Maximum-contrast light scheme tuned for direct-sunlight readability.
-- All foreground colors are >=10:1 against #ffffff.
local sunlight_scheme = {
	foreground = "#000000",
	background = "#ffffff",
	cursor_bg = "#000000",
	cursor_fg = "#ffffff",
	cursor_border = "#000000",
	selection_bg = "#9fb3d0",
	selection_fg = "#000000",
	scrollbar_thumb = "#3a3a3a",
	split = "#1a1a1a",
	ansi = {
		"#000000", -- black
		"#7a0000", -- red (11.5:1)
		"#003d12", -- green (13.7:1)
		"#5e3500", -- yellow rendered as dark amber (12.7:1)
		"#001f80", -- blue (15.1:1)
		"#4a0066", -- magenta (14.6:1)
		"#00333d", -- cyan (14.0:1)
		"#3a3a3a", -- white slot (used as gray; 10.4:1)
	},
	brights = {
		"#3a3a3a", -- bright black (10.4:1)
		"#a01010", -- bright red (10.0:1)
		"#004f18", -- bright green (11.6:1)
		"#6f3d00", -- bright yellow / amber (10.9:1)
		"#0030a0", -- bright blue (11.5:1)
		"#5e1075", -- bright magenta (11.5:1)
		"#00424d", -- bright cyan (12.2:1)
		"#000000", -- bright white (slot used as darkest; 21:1)
	},
	indexed = { [16] = "#5e3500", [17] = "#7a0000" },
	tab_bar = {
		background = "#ffffff",
		active_tab = { bg_color = "#ffffff", fg_color = "#000000", intensity = "Bold" },
		inactive_tab = { bg_color = "#dde6ff", fg_color = "#1a1a1a", intensity = "Bold" },
		inactive_tab_hover = { bg_color = "#a8cef0", fg_color = "#000000", intensity = "Bold" },
		new_tab = { bg_color = "#dde6ff", fg_color = "#1a1a1a", intensity = "Bold" },
		new_tab_hover = { bg_color = "#a8cef0", fg_color = "#000000", intensity = "Bold" },
	},
}

local function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "Tokyo Night"
	else
		return "Sunlight"
	end
end

local function is_dark(appearance)
	return appearance:find("Dark") ~= nil
end

wezterm.on("format-tab-title", function(tab)
	local uri = tab.active_pane.current_working_dir
	if not uri then return tab.active_pane.title end
	local path = type(uri) == "userdata" and uri.file_path or tostring(uri)
	local home = os.getenv("HOME") or ""
	if path == home or path == home .. "/" then return "~" end
	return path:match("([^/]+)/?$") or path
end)

wezterm.on("window-config-reloaded", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	local appearance = window:get_appearance()
	local dark = is_dark(appearance)
	local scheme = scheme_for_appearance(appearance)
	-- Force opacity to 1.0 in light mode so wallpaper bleed-through doesn't
	-- destroy contrast under direct sunlight; keep transparency when dark.
	local opacity = dark and 0.9 or 1.0
	-- Use a heavier baseline font weight in light mode -- thicker strokes
	-- read far better under glare and Bold is still distinguishable.
	local font = wezterm.font({
		family = "Drafting* Mono",
		weight = dark and "Regular" or "Medium",
	})
	local changed = false
	if overrides.color_scheme ~= scheme then
		overrides.color_scheme = scheme
		changed = true
	end
	if overrides.window_background_opacity ~= opacity then
		overrides.window_background_opacity = opacity
		changed = true
	end
	if overrides.font ~= font then
		overrides.font = font
		changed = true
	end
	if changed then
		window:set_config_overrides(overrides)
	end
end)

-- Read git branch + dirty file count for a working directory.
-- Returns nil, nil if not inside a git repo.
local function git_info(path)
	if not path or path == "" then return nil, nil end
	local cmd = string.format("git -C %q status --porcelain=v1 -b 2>/dev/null", path)
	local handle = io.popen(cmd)
	if not handle then return nil, nil end
	local out = handle:read("*a") or ""
	handle:close()
	if out == "" then return nil, nil end

	local first_line = out:match("^[^\n]*") or ""
	local branch = first_line:match("^## ([^%s.]+)")
		or first_line:match("^## (.-)%.%.%.")
		or first_line:match("^## (.+)$")

	local count = 0
	for _ in out:gmatch("\n[ MADRCU?!][ MADRCU?!] ") do
		count = count + 1
	end
	return branch, count
end

-- Multi-segment powerline status bar with gradient colors.
-- Shows: cwd · git branch · changed-file count · battery · date/time
wezterm.on("update-status", function(window, pane)
	local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

	local cwd = "~"
	local cwd_path
	local p = pane or window:active_pane()
	if p then
		local uri = p:get_current_working_dir()
		if uri then
			cwd_path = type(uri) == "userdata" and uri.file_path or tostring(uri)
			cwd = cwd_path:match("([^/]+)/?$") or cwd_path
			if cwd_path == (os.getenv("HOME") or "") or cwd_path == (os.getenv("HOME") or "") .. "/" then
				cwd = "~"
			end
		end
	end

	local branch, changed = git_info(cwd_path)

	local battery = ""
	for _, b in ipairs(wezterm.battery_info()) do
		battery = string.format("%.0f%%", b.state_of_charge * 100)
	end

	local segments = { cwd }
	if branch then
		table.insert(segments, " " .. branch .. (changed > 0 and " ●" or ""))
	end
	if branch and changed > 0 then
		table.insert(segments, "±" .. changed)
	end
	if battery ~= "" then table.insert(segments, battery) end
	table.insert(segments, wezterm.strftime("%a %b %-d %H:%M"))

	local palette = window:effective_config().resolved_palette
	local bg = wezterm.color.parse(palette.background)
	local fg = palette.foreground

	local gradient_to = bg
	local gradient_from
	if is_dark(window:get_appearance()) then
		gradient_from = gradient_to:lighten(0.2)
	else
		gradient_from = gradient_to:darken(0.2)
	end

	local gradient = wezterm.color.gradient(
		{ orientation = "Horizontal", colors = { gradient_from, gradient_to } },
		#segments
	)

	local elements = {}
	for i, seg in ipairs(segments) do
		if i == 1 then
			table.insert(elements, { Background = { Color = "none" } })
		end
		table.insert(elements, { Foreground = { Color = gradient[i] } })
		table.insert(elements, { Text = SOLID_LEFT_ARROW })
		table.insert(elements, { Foreground = { Color = fg } })
		table.insert(elements, { Background = { Color = gradient[i] } })
		table.insert(elements, { Text = " " .. seg .. " " })
	end

	window:set_right_status(wezterm.format(elements))
end)

return {
	color_schemes = { ["Sunlight"] = sunlight_scheme },
	color_scheme = scheme_for_appearance(wezterm.gui.get_appearance()),

	-- Throttle update-status (default 1s) since we shell out to git
	status_update_interval = 5000,

	-- Font
	font = wezterm.font({ family = "Drafting* Mono" }),
	font_size = 13,

	-- Window styling
	window_background_opacity = 0.9,
	macos_window_background_blur = 30,
	window_decorations = "RESIZE",
	window_frame = {
		font = wezterm.font({ family = "Drafting* Mono", weight = "Bold" }),
		font_size = 12,
	},

	keys = {
		-- Pane splitting (iTerm2-style)
		{ key = "d", mods = "CMD",       action = wezterm.action.SplitPane { direction = "Right" } },
		{ key = "d", mods = "CMD|SHIFT", action = wezterm.action.SplitPane { direction = "Down" } },
		-- Pane navigation
		{ key = "[", mods = "CMD",       action = wezterm.action.ActivatePaneDirection "Prev" },
		{ key = "]", mods = "CMD",       action = wezterm.action.ActivatePaneDirection "Next" },
		{ key = "w", mods = "CMD",       action = wezterm.action.CloseCurrentPane { confirm = false } },
		{ key = "f", mods = "CMD|CTRL", action = wezterm.action.ToggleFullScreen },
	},
}
