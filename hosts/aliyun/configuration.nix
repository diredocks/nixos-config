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
    ./hardware/boot.nix
    ./hardware/disko.nix
    ./hardware/hardware-configuration.nix
    ./sing-box.nix
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [80 443];
    allowedUDPPorts = [80 443 3478 41641];
  };
  services.resolved.enable = false;
  networking.useDHCP = false;
  networking.nameservers = [
    "1.1.1.1"
  ];
  systemd.network.enable = true;
  systemd.network.networks.eth0 = {
    networkConfig.DHCP = "ipv4";
    matchConfig.Name = "eth0";
  };

  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";

  nix = {
    settings.substituters = lib.mkForce [
      "https://cache.nixos.org?priority=1"
    ];
    gc = {
      automatic = true;
      dates = "daily";
    };
  };

  services.openssh.ports = [29381];
}
