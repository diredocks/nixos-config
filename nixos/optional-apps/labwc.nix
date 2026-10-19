{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  programs.labwc = {
    enable = true;
  };
  environment.systemPackages = with pkgs; [
    bemenu
    waybar
    swaybg
    wtype
    wmctrl
    xdotool
    libinput-gestures
    adwaita-icon-theme
  ];
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.labwc}/bin/labwc";
        user = "leo";
      };
      default_session = initial_session;
    };
  };
}
