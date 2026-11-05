{
  lib,
  pkgs,
  ...
}: {
  boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux-ophub;

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.kernelParams = ["earlycon" "console=ttyS2,1500000" "consoleblank=0"];

  hardware.deviceTree = {
    enable = true;
    name = "rockchip/rk3399-tpm312.dtb";
    # only this board's dtb ends up in /boot
    filter = "rk3399-tpm312.dtb";
  };

  # dw_mmc/arasan, stmmac and ext4/btrfs are built in, and NixOS's default
  # initrd modules (ahci, virtio, ...) don't exist in this kernel.
  boot.initrd.includeDefaultModules = false;
  boot.initrd.allowMissingModules = true;
  boot.initrd.availableKernelModules = ["usb_storage" "uas"];

  # profiles/base.nix enables ZFS, which needs out-of-tree modules;
  # the prebuilt kernel has no dev output.
  boot.supportedFilesystems.zfs = lib.mkForce false;

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
}
