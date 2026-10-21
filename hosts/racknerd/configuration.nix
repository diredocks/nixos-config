{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  LT,
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

  time.timeZone = "America/Denver";
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

  users.users.${LT.user}.openssh.authorizedKeys.keys = [
    sshKeys.users.leo_probook-nix
  ];

  services.tailscale.enable = true;

  environment.systemPackages = with pkgs; [
    tailscale
    sing-box
  ];

  services.sing-box = {
    enable = true;
    settingsFile = config.age.secrets.racknerd-sb-conf.path;
  };
  systemd.services.sing-box.restartTriggers = ["${config.age.secrets.racknerd-sb-conf.file}"];
  age.secrets.racknerd-sb-conf.file = ../../secrets/racknerd-sb-config.json;

  services.openssh.ports = [24228];
}
