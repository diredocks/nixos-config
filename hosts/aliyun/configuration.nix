{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  sshKeys = import ../../secrets/ssh-keys-pub.nix;
in {
  imports = [
    ./hardware/boot.nix
    ./hardware/disko.nix
    ./hardware/hardware-configuration.nix
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [80 443 8010];
    allowedUDPPorts = [80 443 3478];
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

  users.users = {
    leo = {
      initialPassword = "1";
      isNormalUser = true;
      extraGroups = ["wheel"];
      openssh.authorizedKeys.keys = [
        sshKeys.users.leo_probook-nix
      ];
    };
  };

  services.tailscale.enable = true;

  environment.systemPackages = with pkgs; [
    tailscale
    sing-box
  ];

  services.sing-box = {
    enable = true;
    settingsFile = config.age.secrets.aliyun-sb-conf.path;
  };
  systemd.services.sing-box.restartTriggers = ["${config.age.secrets.aliyun-sb-conf.file}"];
  age.secrets.aliyun-sb-conf.file = ../../secrets/aliyun-sb-config.json;

  services.openssh.ports = [29381];
}
