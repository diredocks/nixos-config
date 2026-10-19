{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        decorations_theme_variant = "dark";
        dimensions = {
          columns = 115;
          lines = 35;
        };
      };
      font = {
        size = 14.0;
        normal = {
          family = "ComicShannsMono Nerd Font";
        };
      };
      mouse = {
        hide_when_typing = true;
      };
      colors = {
        primary = {
          background = "#24283b";
          foreground = "#a9b1d6";
        };

        normal = {
          black = "#32344a";
          red = "#f7768e";
          green = "#9ece6a";
          yellow = "#e0af68";
          blue = "#7aa2f7";
          magenta = "#ad8ee6";
          cyan = "#449dab";
          white = "#9699a8";
        };

        bright = {
          black = "#444b6a";
          red = "#ff7a93";
          green = "#b9f27c";
          yellow = "#ff9e64";
          blue = "#7da6ff";
          magenta = "#bb9af7";
          cyan = "#0db9d7";
          white = "#acb0d0";
        };
      };
    };
  };
}
