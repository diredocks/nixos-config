{
  pkgs,
  config,
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
}
