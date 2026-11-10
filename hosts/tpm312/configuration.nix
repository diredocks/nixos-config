{...}: {
  imports = [
    ./hardware/hardware-configuration.nix
    ./hardware/sd-image.nix
    ./nginx.nix
    ./sing-box.nix
    ./magpie.nix
    ./immich.nix
  ];

  networking.networkmanager.enable = true;
  networking.firewall.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";

  services.openssh.settings.PermitRootLogin = "yes";

  virtualisation.containers.containersConf.settings = {
    engine = {
      env = [
        "http_proxy=http://127.0.0.1:36176"
        "https_proxy=http://127.0.0.1:36176"
      ];
    };
    containers.http_proxy = false;
  };

  services.journald.settings.Journal = {
    Storage = "volatile";
    RuntimeMaxUse = "64M";
    RuntimeKeepFree = "64M";
    SyncIntervalSec = "5min";
  };
}
