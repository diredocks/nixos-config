{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "ComicShannsMono Nerd Font";
      window-height = 35;
      window-width = 115;
      font-size = 15;
      mouse-hide-while-typing = true;
      cursor-style = "block";
      cursor-style-blink = false;
      shell-integration-features = "no-cursor";
      window-theme = "dark";
      theme = "tokyonight-storm";
      gtk-single-instance = true;
      window-padding-x = 0;
      window-padding-y = 0;
    };
  };
}
