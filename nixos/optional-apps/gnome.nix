{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  services = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };
  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "leo";
  };
  services.gnome.games.enable = false;
  services.gnome.gnome-keyring.enable = true;
  environment.gnome.excludePackages = with pkgs; [
    baobab
    decibels
    epiphany
    gnome-maps
    gnome-music
    gnome-connections
    gnome-console
    totem
    yelp
    simple-scan
    geary
  ];
  environment.systemPackages = with pkgs; [
    gnome-tweaks
    gnomeExtensions.kimpanel
    gnomeExtensions.appindicator
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.alphabetical-app-grid
    gnomeExtensions.rounded-window-corners-reborn
  ];
  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "foot";
  };
}
