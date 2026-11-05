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
  networking.useDHCP = false;
  networking.nameservers = [
    "1.1.1.1"
  ];
  systemd.network.enable = true;
  services.resolved.enable = false;
  age.secrets.vmiss-la-addr = {
    file = ../../secrets/vmiss-la-eth0.network;
    path = "/etc/systemd/network/vmiss-la-eth0.network";
    mode = "444";
    symlink = true;
  };

  time.timeZone = "America/Los_Angeles";
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

  services.openssh.ports = [41867];
}
