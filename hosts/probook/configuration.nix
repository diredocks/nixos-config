# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  LT,
  ...
}: {
  imports = [
    ./hardware/hardware-configuration.nix
    ./hardware/boot.nix
  ];

  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  boot.tmp.useTmpfs = true;
  boot.binfmt.emulatedSystems = ["aarch64-linux"]; # For building aarch64 images

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.${LT.user}.extraGroups = ["dialout"];

  services.keyd = {
    enable = true;
    keyboards = {
      all = {
        ids = ["*"];
        settings.main = {
          capslock = "backspace";
        };
      };
    };
  };
}
