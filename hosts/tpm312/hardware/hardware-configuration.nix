{
  lib,
  pkgs,
  ...
}: {
  # Kernel, modules and dtb all come from ophub/kernel (pkgs/linux-ophub.nix).
  boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux-ophub;

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.kernelParams = ["earlycon" "console=ttyS2,1500000" "consoleblank=0"];

  hardware.deviceTree = {
    enable = true;
    # dtbSource defaults to ${kernel}/dtbs, i.e. ophub's dtb-rockchip package.
    name = "rockchip/rk3399-tpm312.dtb";
    # Only copy this one dtb into /boot for every generation.
    filter = "rk3399-tpm312.dtb";
  };

  # eMMC/SD (dw_mmc, arasan, emmc phy), stmmac gmac, ext4/btrfs/vfat are all
  # built into the ophub kernel, so the initrd needs no extra modules. Don't
  # pull in NixOS's default list (ahci, virtio, ...): many don't exist here.
  boot.initrd.includeDefaultModules = false;
  boot.initrd.allowMissingModules = true;
  boot.initrd.availableKernelModules = ["usb_storage" "uas"];

  # profiles/base.nix enables ZFS by default, which needs out-of-tree modules
  # built against the kernel's dev output; the prebuilt kernel has none.
  boot.supportedFilesystems.zfs = lib.mkForce false;
}
