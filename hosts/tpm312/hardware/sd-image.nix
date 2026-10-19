{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/base.nix")
    ../../../nixos/hardware/sd-image.nix
  ];

  # TODO: Uboot from https://github.com/ophub/u-boot/tree/main/u-boot/rockchip/tpm312
  sdImage = {
    imageBaseName = "nixos-sd-image-tpm312";
    firmwarePartitionOffset = 32;
    populateFirmwareCommands = "";
    populateRootCommands = ''
      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
    '';
    postBuildCommands = ''
      # puts the Rockchip header and SPL image first at block 64 (0x40)
      #dd if=/idbloader.img of=$img seek=64 conv=notrunc
      # places the U-Boot image at block 16384 (0x4000)
      #dd if=/u-boot.itb of=$img seek=16384 conv=notrunc
    '';
  };
}
