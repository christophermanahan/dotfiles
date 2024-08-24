local wezterm = require("wezterm")
local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config = {
	front_end = "WebGpu",
	color_scheme = "Catppuccin Mocha",
	set_environment_variables = {
		PATH = "/usr/local/bin:/usr/bin",
	},
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
	default_cursor_style = "SteadyBar",
	automatically_reload_config = true,
	window_close_confirmation = "NeverPrompt",
	adjust_window_size_when_changing_font_size = false,
	window_decorations = "RESIZE",
	check_for_updates = true,
	enable_tab_bar = true,
	use_fancy_tab_bar = true,
	tab_bar_at_bottom = false,
	show_close_tab_button_in_tabs = false,
	show_new_tab_button_in_tab_bar = false,
	font_size = 13,
	font = wezterm.font("Hack Nerd Font"),
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
	background = {
		{
			source = {
				File = "/Users/" .. os.getenv("USER") .. "/.config/wezterm/bg-monterey.png",
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
			opacity = 0.55,
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
