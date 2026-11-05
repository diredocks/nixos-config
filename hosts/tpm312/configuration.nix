{
  pkgs,
  config,
  LT,
  ...
}: {
  imports = [
    ./hardware/hardware-configuration.nix
    ./hardware/sd-image.nix
  ];

  networking.networkmanager.enable = true;
  networking.firewall.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";

  services.openssh.settings.PermitRootLogin = "yes";

  services.tailscale.enable = true;
  environment.systemPackages = with pkgs; [
    tailscale
    sing-box
  ];

  services.sing-box = {
    enable = true;
    settingsFile = config.age.secrets.tpm-sb-conf.path;
  };
  systemd.services.sing-box.restartTriggers = ["${config.age.secrets.tpm-sb-conf.file}"];
  age.secrets.tpm-sb-conf.file = ../../secrets/tpm-sb-config.json;

  virtualisation.containers.containersConf.settings = {
    engine = {
      env = [
        "http_proxy=http://127.0.0.1:36176"
        "https_proxy=http://127.0.0.1:36176"
      ];
    };
    containers.http_proxy = false;
  };

  virtualisation.oci-containers = {
    containers.magpie = {
      image = "ghcr.io/yetone/magpie:latest";
      ports = ["127.0.0.1:4820:3425" "127.0.0.1:4830:3430"];
      volumes = ["magpie:/config"];
      cmd = [
        "web"
        "--addr"
        "0.0.0.0:3430"
        "--no-open"
      ];
      environment = {
        http_proxy = "http://host.containers.internal:36176";
        https_proxy = "http://host.containers.internal:36176";
      };
      extraOptions = [
        "--env=MAGPIE_WEB_KEY"
        "--network=pasta:--map-host-loopback,169.254.1.2"
      ];
      autoStart = true;
      podman.user = LT.user;
    };
  };

  age.secrets.magpie-key.file = ../../secrets/magpie.key;
  systemd.services.podman-magpie = {
    serviceConfig.EnvironmentFile = config.age.secrets.magpie-key.path;
    restartTriggers = ["${config.age.secrets.magpie-key.file}"];
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."magpie.tpm.clickfling.top" = {
      forceSSL = true;
      useACMEHost = "tpm";
      locations."/".proxyPass = "http://127.0.0.1:4830";
    };

    virtualHosts."gateway.tpm.clickfling.top" = {
      forceSSL = true;
      useACMEHost = "tpm";
      locations."/".proxyPass = "http://127.0.0.1:4820";
    };
  };

  security.acme = {
    acceptTerms = true;
    certs."tpm" = {
      domain = "*.tpm.clickfling.top";
      dnsProvider = "cloudflare";
      environmentFile = config.age.secrets.cloudflare-dns.path;
      group = config.services.nginx.group;
    };
  };

  age.secrets.cloudflare-dns.file = ../../secrets/cloudflare-dns.key;
}
