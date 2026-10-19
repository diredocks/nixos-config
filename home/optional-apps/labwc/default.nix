{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  xdg.configFile = {
    "libinput-gestures.conf".source = ./libinput-gestures.conf;
    "waybar".source = ./waybar;
    "labwc".source = ./labwc;
  };
  xdg.dataFile."themes/Umbra".source = ./Umbra;
}
