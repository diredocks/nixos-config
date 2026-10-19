{
  config,
  pkgs,
  ...
}: {
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require "wezterm"
      local act = wezterm.action

      return {

      font_size = 12.0,
      cell_width = 0.9,
      line_height = 0.9,
      font = wezterm.font_with_fallback { "JetBrainsMono Nerd Font", "Noto Sans Mono CJK SC" },
      color_scheme = "Tokyo Night Storm",

      enable_tab_bar = true,
      tab_bar_at_bottom = true,
      use_fancy_tab_bar = false,
      hide_tab_bar_if_only_one_tab = true,

      initial_cols = 160,
      initial_rows = 45,

      animation_fps = 1,
      hide_mouse_cursor_when_typing = true,
      window_close_confirmation = "NeverPrompt",

      window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
      },

      leader = { key = "x", mods = "CTRL", timeout_milliseconds = 900 },

      keys = {
        { key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
        { key = ",", mods = "LEADER", action = act.PromptInputLine {
            description = "Rename tab",
            action = wezterm.action_callback(function(window, pane, line)
              if line then
                window:active_tab():set_title(line)
              end
            end),
          },
        },
        { key = "d", mods = "LEADER", action = act.CloseCurrentTab { confirm = true } },
        {
          key = "j", mods = "LEADER",
          action = wezterm.action_callback(function(window, pane)
            local tabs = window:mux_window():tabs()
            if #tabs <= 1 then
              window:perform_action(act.SpawnTab("CurrentPaneDomain"), pane)
            else
              window:perform_action(act.ActivateTabRelative(1), pane)
            end
          end),
        },
        { key = "k", mods = "LEADER", action = act.ActivateTabRelative(-1) },
      },

      mouse_bindings = {
        {
          event = { Up = { streak = 1, button = "Left" } },
          mods = "NONE",
          action = act.Nop,
        },
        {
          event = { Up = { streak = 1, button = "Left" } },
          mods = "SHIFT",
          action = act.OpenLinkAtMouseCursor,
        },
        {
          event = { Up = { streak = 2, button = "Left" } },
          mods = "NONE",
          action = act.Nop,
        },
        {
          event = { Up = { streak = 3, button = "Left" } },
          mods = "NONE",
          action = act.Nop,
        },
      },

      }
    '';
  };
}
