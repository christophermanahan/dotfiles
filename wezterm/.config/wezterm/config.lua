---@diagnostic disable: undefined-field
local wezterm = require("wezterm")
local config = wezterm.config_builder()
local mux = wezterm.mux

local process_icons = {
	["docker"] = wezterm.nerdfonts.linux_docker,
	["docker-compose"] = wezterm.nerdfonts.linux_docker,
	["psql"] = "󱤢",
	["usql"] = "󱤢",
	["kuberlr"] = wezterm.nerdfonts.linux_docker,
	["kubectl"] = wezterm.nerdfonts.linux_docker,
	["stern"] = wezterm.nerdfonts.linux_docker,
	["nvim"] = wezterm.nerdfonts.custom_vim,
	["make"] = wezterm.nerdfonts.seti_makefile,
	["vim"] = wezterm.nerdfonts.dev_vim,
	["node"] = wezterm.nerdfonts.dev_nodejs_small,
	["go"] = wezterm.nerdfonts.seti_go,
	["zsh"] = wezterm.nerdfonts.dev_terminal,
	["bash"] = wezterm.nerdfonts.cod_terminal_bash,
	["btm"] = wezterm.nerdfonts.mdi_chart_donut_variant,
	["htop"] = wezterm.nerdfonts.mdi_chart_donut_variant,
	["cargo"] = wezterm.nerdfonts.dev_rust,
	["sudo"] = wezterm.nerdfonts.fa_hashtag,
	["lazydocker"] = wezterm.nerdfonts.linux_docker,
	["git"] = wezterm.nerdfonts.dev_git,
	["lua"] = wezterm.nerdfonts.seti_lua,
	["wget"] = wezterm.nerdfonts.mdi_arrow_down_box,
	["curl"] = wezterm.nerdfonts.mdi_flattr,
	["gh"] = wezterm.nerdfonts.dev_github_badge,
	["ruby"] = wezterm.nerdfonts.cod_ruby,
	["Python"] = wezterm.nerdfonts.dev_python,
}

-- Return the Tab's current working directory
local function get_cwd(tab)
	local cwd = tab.active_pane and tab.active_pane.current_working_dir
	if cwd and cwd.file_path then
		return cwd.file_path
	end
	return ""
end

-- Remove all path components and return only the last value
local function remove_abs_path(path)
	return path:gsub("(.*[/\\])(.*)", "%2")
end

-- Return the pretty path of the tab's current working directory
local function get_display_cwd(tab)
	local current_dir = get_cwd(tab)
	return current_dir == os.getenv("HOME") and "~" or remove_abs_path(current_dir)
end

-- Return the concise name or icon of the running process for display
local function get_process(tab)
	if not tab.active_pane or tab.active_pane.foreground_process_name == "" then
		return "[?]"
	end

	local process_name = remove_abs_path(tab.active_pane.foreground_process_name)
	if process_name:find("kubectl") then
		process_name = "kubectl"
	end

	return wezterm.format({
		{ Attribute = { Italic = true } },
		{ Text = process_icons[process_name] },
	}) or string.format("%s", process_name)
end

-- Pretty format the tab title
local function format_title(tab)
	local index = string.format("%s%s", tab.tab_index + 1, ")")
	local cwd = get_display_cwd(tab)
	local process = get_process(tab)

	return string.format(" %s %s %s ", index, process, cwd)
end

-- Determine if a tab has unseen output since last visited
local function has_unseen_output(tab)
	if not tab.is_active then
		for _, pane in ipairs(tab.panes) do
			if pane.has_unseen_output then
				return true
			end
		end
	end
	return false
end

-- Convert arbitrary strings to a unique hex color value
local function string_to_color(str)
	-- Convert the string to a unique integer
	local hash = 0
	for i = 1, #str do
		hash = string.byte(str, i) + ((hash << 5) - hash)
	end

	-- Convert the integer to a unique color
	local c = string.format("%06X", hash & 0x00FFFFFF)
	return "#" .. (string.rep("0", 6 - #c) .. c):upper()
end

local function select_contrasting_fg_color(hex_color)
	local color = wezterm.color.parse(hex_color)
	local lightness, _, _, _ = color:laba()
	if lightness > 55 then
		return "#000000"
	end
	return "#FFFFFF"
end

wezterm.on("format-tab-title", function(tab)
	local title = format_title(tab)
	local color = string_to_color(get_cwd(tab))

	if tab.is_active then
		return {
			{ Background = { Color = color } },
			{ Foreground = { Color = select_contrasting_fg_color(color) } },
			{ Text = title },
		}
	end

	if has_unseen_output(tab) then
		return {
			{ Foreground = { Color = "#EBD168" } },
			{ Text = title },
		}
	end
	return title
end)

wezterm.on("gui-attached", function()
	local workspace = mux.get_active_workspace()
	for _, window in ipairs(mux.all_windows()) do
		if window:get_workspace() == workspace then
			window:gui_window():maximize()
		end
	end
end)

wezterm.on("update-status", function(window)
	local cells = {}

	-- Figure out the hostname of the pane on a best-effort basis
	local hostname = wezterm.hostname()
	table.insert(cells, "  " .. hostname)

	-- Format date/time in this style: "Wed Mar 3 08:14"
	local date = wezterm.strftime("  %a %b %-d %l:%M %p")
	table.insert(cells, date)

	-- Add an entry for each battery (typically 0 or 1)
	local batt_icons = { "", "", "", "", "" }
	for _, b in ipairs(wezterm.battery_info()) do
		local curr_batt_icon = batt_icons[math.ceil(b.state_of_charge * #batt_icons)]
		table.insert(cells, string.format("%s  %.0f%%", curr_batt_icon, b.state_of_charge * 100))
	end

	local text_fg = "black"
	local colors = {
		"rgba(0, 0, 0, 0)",
		"#94e2d5",
		"#74c7ec",
		"#89b4fa",
	}

	local elements = {}
	while #cells > 0 and #colors > 1 do
		local text = table.remove(cells, 1)
		local prev_color = table.remove(colors, 1)
		local curr_color = colors[1]

		table.insert(elements, { Background = { Color = prev_color } })
		table.insert(elements, { Foreground = { Color = curr_color } })
		table.insert(elements, { Text = "" })
		table.insert(elements, { Background = { Color = curr_color } })
		table.insert(elements, { Foreground = { Color = text_fg } })
		table.insert(elements, { Text = " " .. text .. " " })
	end
	window:set_right_status(wezterm.format(elements))
end)

config = {
	front_end = "WebGpu",
	color_scheme = "catppuccin-mocha",
	set_environment_variables = {
		PATH = "/usr/local/bin:/usr/bin",
	},
	enable_kitty_keyboard = false,
	leader = { key = "a", mods = "CTRL" },
	keys = {
		{
			key = "'",
			mods = "CTRL",
			action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
		},
		{
			key = "b",
			mods = "CTRL",
			action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
		},
		{
			key = "w",
			mods = "CMD",
			action = wezterm.action.CloseCurrentTab({ confirm = false }),
		},
		{
			key = "w",
			mods = "ALT",
			action = wezterm.action.CloseCurrentPane({ confirm = false }),
		},
		{
			key = "l",
			mods = "CMD",
			action = wezterm.action.SendKey({ key = "l", mods = "CTRL" }),
		},
		{
			key = "x",
			mods = "CTRL",
			action = wezterm.action.ActivateCopyMode,
		},
		{
			key = "z",
			mods = "CTRL",
			action = wezterm.action.TogglePaneZoomState,
		},
		{
			key = "h",
			mods = "LEADER",
			action = wezterm.action.AdjustPaneSize({ "Left", 10 }),
		},
		{
			key = "j",
			mods = "LEADER",
			action = wezterm.action.AdjustPaneSize({ "Down", 10 }),
		},
		{
			key = "k",
			mods = "LEADER",
			action = wezterm.action.AdjustPaneSize({ "Up", 10 }),
		},
		{
			key = "l",
			mods = "LEADER",
			action = wezterm.action.AdjustPaneSize({ "Right", 10 }),
		},
		{
			key = "w",
			mods = "LEADER",
			action = wezterm.action.ShowTabNavigator,
		},
		{
			key = "f",
			mods = "LEADER",
			action = wezterm.action.ToggleFullScreen,
		},
		{
			key = "h",
			mods = "CMD|SHIFT",
			action = wezterm.action.MoveTabRelative(-1),
		},
		{
			key = "l",
			mods = "CMD|SHIFT",
			action = wezterm.action.MoveTabRelative(1),
		},
	},
	window_frame = {
		font = wezterm.font("Hack Nerd Font"),
		font_size = 12,
		active_titlebar_bg = "rgba(0, 0, 0, 0)",
		inactive_titlebar_bg = "rgba(0, 0, 0, 0)",
	},
	colors = {
		tab_bar = {
			inactive_tab_edge = "rgba(0, 0, 0, 0)",
		},
	},
	term = "xterm-256color",
	default_cursor_style = "SteadyBar",
	automatically_reload_config = true,
	window_close_confirmation = "NeverPrompt",
	adjust_window_size_when_changing_font_size = false,
	window_decorations = "RESIZE",
	check_for_updates = true,
	show_tabs_in_tab_bar = true,
	use_fancy_tab_bar = true,
	tab_bar_at_bottom = false,
	show_new_tab_button_in_tab_bar = false,
	font_size = 13,
	font = wezterm.font("Hack Nerd Font", { weight = "Regular", stretch = "Normal", style = "Normal" }),
	warn_about_missing_glyphs = false,
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
	background = {
		{
			source = {
				File = "/Users/" .. os.getenv("USER") .. "/.config/wezterm/abstract-geometry.jpg",
			},
			hsb = {
				hue = 1.0,
				saturation = 1.02,
				brightness = 0.25,
			},
		},
		{
			source = {
				Color = "#282c35",
			},
			width = "100%",
			height = "100%",
			opacity = 0.3,
		},
	},
	-- from: https://akos.ma/blog/adopting-wezterm/
	hyperlink_rules = {
		-- Matches: a URL in parens: (URL)
		{
			regex = "\\((\\w+://\\S+)\\)",
			format = "$1",
			highlight = 1,
		},
		-- Matches: a URL in brackets: [URL]
		{
			regex = "\\[(\\w+://\\S+)\\]",
			format = "$1",
			highlight = 1,
		},
		-- Matches: a URL in curly braces: {URL}
		{
			regex = "\\{(\\w+://\\S+)\\}",
			format = "$1",
			highlight = 1,
		},
		-- Matches: a URL in angle brackets: <URL>
		{
			regex = "<(\\w+://\\S+)>",
			format = "$1",
			highlight = 1,
		},
		-- Then handle URLs not wrapped in brackets
		{
			-- Before
			--regex = '\\b\\w+://\\S+[)/a-zA-Z0-9-]+',
			--format = '$0',
			-- After
			regex = "[^(]\\b(\\w+://\\S+[)/a-zA-Z0-9-]+)",
			format = "$1",
			highlight = 1,
		},
		-- implicit mailto link
		{
			regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b",
			format = "mailto:$0",
		},
	},
}

local smart_splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")
smart_splits.apply_to_config(config, {
	direction_keys = { "h", "j", "k", "l" },
	modifiers = {
		move = "CTRL",
	},
})

return config
