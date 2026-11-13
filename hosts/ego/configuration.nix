{
  inputs,
  LT,
  ...
}: {
  imports = [
    # The gaokun3 flake's own NixOS module, applied with the one line below.
    inputs.gaokun3.nixosModules.gaokun3
    # disko owns the partition table and the resulting `fileSystems`; the host
    # dir therefore has no hardware-configuration.nix.
    ./hardware/disko.nix
    ./hardware/boot.nix
    # The BOE panel correction for this machine; the installer imports it too.
    ./hardware/panel.nix
  ];

  # Hardware support for the MateBook E Go: kernel, device tree, kernel command
  # line, initrd/boot modules, firmware, Bluetooth NVM patch, audio UCM and the
  # display rotation. `nixpkgs.config.allowUnfree = true` in
  # nixos/minimal-components/nix.nix already covers linux-firmware-gaokun3, so
  # no allowUnfreePredicate is needed here.
  hardware.gaokun3.enable = true;

  # Wi-Fi only; there is no wired port on this device.
  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.${LT.user}.extraGroups = ["dialout"];
}
