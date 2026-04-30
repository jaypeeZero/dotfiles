local wezterm = require("wezterm")

local function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "Tokyo Night"
	else
		return "Catppuccin Latte"
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
	local scheme = scheme_for_appearance(window:get_appearance())
	if overrides.color_scheme ~= scheme then
		overrides.color_scheme = scheme
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
