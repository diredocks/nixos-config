{
  inputs,
  config,
  LT,
  ...
}: {
  imports = [
    ./hardware/disko.nix
    ./hardware/boot.nix
    ./hardware/hardware-configuration.nix
  ];

  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.${LT.user}.extraGroups = ["dialout" "video"];
  systemd.services.display-manager.preStart = ''
    ${config.systemd.package}/bin/udevadm wait --timeout=30 /dev/dri/card1 || true
  '';
}
