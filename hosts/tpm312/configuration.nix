{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
in {
  imports = [
    #./hardware/boot.nix
    #./hardware/disko.nix
    ./hardware/hardware-configuration.nix
    ./hardware/sd-image.nix
  ];

  networking.networkmanager.enable = true;
  networking.firewall.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users = {
    leo = {
      initialPassword = "1";
      isNormalUser = true;
      extraGroups = ["wheel"];
    };
  };

  services.openssh.settings.PermitRootLogin = "yes";

  services.tailscale.enable = true;
  environment.systemPackages = with pkgs; [
    tailscale
  ];
}
