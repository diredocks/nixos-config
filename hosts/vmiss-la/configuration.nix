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

  networking.firewall.enable = false;
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
    settingsFile = config.age.secrets.vmiss-la-sb-conf.path;
  };
  systemd.services.sing-box.restartTriggers = ["${config.age.secrets.vmiss-la-sb-conf.file}"];
  age.secrets.vmiss-la-sb-conf.file = ../../secrets/vmiss-la-sb-config.json;

  services.openssh.ports = [41867];
}
