{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  services.tailscale.enable = true;
  environment.systemPackages = with pkgs; [
    tailscale
  ];
  services.flatpak.enable = true;
}
