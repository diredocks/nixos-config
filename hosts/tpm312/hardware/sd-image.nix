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

  image.baseName = "nixos-sd-image-tpm312";

  sdImage = {
    compressImage = false;
    firmwareSize = 1;
    firmwarePartitionOffset = 16;
    populateFirmwareCommands = "";
    populateRootCommands = ''
      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
    '';
    postBuildCommands = ''
      dd if=${pkgs.uboot-tpm312}/idbloader.bin of=$img conv=fsync,notrunc bs=512 seek=64
      dd if=${pkgs.uboot-tpm312}/uboot.img of=$img conv=fsync,notrunc bs=512 seek=16384
      dd if=${pkgs.uboot-tpm312}/trust.bin of=$img conv=fsync,notrunc bs=512 seek=24576
    '';
  };
}
