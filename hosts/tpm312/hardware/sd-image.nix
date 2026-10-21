{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/base.nix")
    (modulesPath + "/installer/sd-card/sd-image.nix")
  ];

  # Boot blobs live in the 32 MiB gap (SD and eMMC share the image); root grows on first boot.
  image.baseName = "nixos-sd-image-tpm312";

  # Kernel/initrd/dtb on rootfs, loaded via extlinux.conf distro boot.
  sdImage = {
    # Leave 32 MiB in front of the first partition for the Rockchip boot chain.
    firmwarePartitionOffset = 32;
    populateFirmwareCommands = "";
    populateRootCommands = ''
      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
    '';
    postBuildCommands = ''
      # Same layout as ophub's Armbian images for this board (512-byte sectors):
      # idbloader at 0x40, U-Boot at 0x4000 and ATF BL31 at 0x6000.
      dd if=${pkgs.uboot-tpm312}/idbloader.bin of=$img conv=fsync,notrunc bs=512 seek=64
      dd if=${pkgs.uboot-tpm312}/uboot.img of=$img conv=fsync,notrunc bs=512 seek=16384
      dd if=${pkgs.uboot-tpm312}/trust.bin of=$img conv=fsync,notrunc bs=512 seek=24576
    '';
  };
}
