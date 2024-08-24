local wezterm = require("wezterm")
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
	return tab.active_pane.current_working_dir.file_path or ""
end

-- Remove all path components and return only the last value
local function remove_abs_path(path)
	return path:gsub("(.*[/\\])(.*)", "%2")
end

-- Return the pretty path of the tab's current working directory
local function get_display_cwd(tab)
	local current_dir = get_cwd(tab)
	local HOME_DIR = os.getenv("HOME")
	return current_dir == HOME_DIR and "~" or remove_abs_path(current_dir)
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
	-- Note: this could use `return color:complement_ryb()` instead if you prefer or other builtins!

	local color = wezterm.color.parse(hex_color)
	---@diagnostic disable-next-line: unused-local
	local lightness, _a, _b, _alpha = color:laba()
	if lightness > 55 then
		return "#000000" -- Black has higher contrast with colors perceived to be "bright"
	end
	return "#FFFFFF" -- White has higher contrast
end

-- On format tab title events, override the default handling to return a custom title
---@diagnostic disable-next-line: unused-local
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local title = format_title(tab)
	local color = string_to_color(get_cwd(tab))

	if tab.is_active then
		return {
			{ Attribute = { Intensity = "Bold" } },
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

wezterm.on("gui-attached", function(domain)
	-- maximize all displayed windows on startup
	local workspace = mux.get_active_workspace()
	for _, window in ipairs(mux.all_windows()) do
		if window:get_workspace() == workspace then
			window:gui_window():maximize()
		end
	end
end)
