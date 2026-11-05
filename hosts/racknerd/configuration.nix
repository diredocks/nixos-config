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

  systemd.tmpfiles.rules = [
    "d ${LT.userHome}/.local/share/vaultwarden 0700 ${LT.user} users -"
  ];

  virtualisation.oci-containers = {
    containers.vaultwarden = {
      image = "docker.io/vaultwarden/server:latest";
      ports = ["127.0.0.1:9273:80"];
      volumes = ["${LT.userHome}/.local/share/vaultwarden:/data"];
      autoStart = true;
      podman.user = LT.user;
      environment = {
        DOMAIN = "https://vault.clickfling.top";
        SIGNUPS_ALLOWED = "false";
        INVITATIONS_ALLOWED = "false";
      };
    };
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."vault.clickfling.top" = {
      forceSSL = true;
      enableACME = true;
      locations."/".proxyPass = "http://127.0.0.1:9273";
    };
  };

  security.acme = {
    acceptTerms = true;
  };
}
