{
  config,
  lib,
  pkgs,
  ...
}: {
  # Vendor U-Boot stays in eMMC/NAND; it loads /boot.scr from FAT (see ./sd-image.nix).
  boot.loader.grub.enable = false;

  boot.kernelPackages = pkgs.linuxPackages_6_12;
  boot.kernelParams = [
    # `ttyAML0` last: like Armbian's console="both", the last console is
    # /dev/console, i.e. serial is the primary console (systemd#9899).
    "console=tty1"
    "console=ttyAML0,115200n8"
    "consoleblank=0"
    "no_console_suspend"
    "net.ifnames=0"
  ];

  # Armbian wraps its initramfs with `mkimage -C gzip`, and the vendor U-Boot
  # only understands that. NixOS would default to zstd here, so force gzip.
  boot.initrd.compressor = "gzip";

  # DTS needs PWM_MESON (vcc_core), watchdog and RTL8211F PHY; all off in multi_v7.
  boot.kernelPatches = [
    {
      name = "onecloud-config";
      patch = null;
      extraConfig = ''
        PWM_MESON y
        MESON_WATCHDOG y
        REALTEK_PHY y
      '';
    }
  ];

  # MMC/ext4 are built into multi_v7; no initrd modules needed.
}
