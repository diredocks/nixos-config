# FAT payload for the vendor U-Boot: uImage, uInitrd, boot.scr, dtb.
# Shared by ./sd-image.nix and ./burn-image.nix.
{
  config,
  lib,
  pkgs,
  ...
}: let
  kernel = config.boot.kernelPackages.kernel;
  kernelImage = "${kernel}/${config.system.boot.loader.kernelFile}";
  initrd = "${config.system.build.initialRamdisk}/${config.system.boot.loader.initrdFile}";

  mkimage = "${pkgs.buildPackages.ubootTools}/bin/mkimage"; # runs on the build machine

  uImage = pkgs.runCommandLocal "onecloud-uImage" {} ''
    ${mkimage} -A arm -O linux -T kernel -C none \
      -a 0x00208000 -e 0x00208000 -n "NixOS" -d ${kernelImage} $out
  '';

  # -C gzip must match boot.initrd.compressor; U-Boot decompresses it (cf. Armbian's 99-uboot).
  uInitrd = pkgs.runCommandLocal "onecloud-uInitrd" {} ''
    ${mkimage} -A arm -O linux -T ramdisk -C gzip -n "NixOS initrd" -d ${initrd} $out
  '';

  # DTS is not upstream; compile the vendored one against this kernel.
  kernelSource = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/source";
  dtb = pkgs.deviceTree.compileDTS {
    name = "meson8b-onecloud.dtb";
    dtsFile = ./meson8b-onecloud.dts;
    includePaths = [
      "${kernelSource}/arch/arm/boot/dts/amlogic"
      "${kernelSource}/arch/arm/boot/dts"
      "${kernelSource}/scripts/dtc/include-prefixes"
    ];
  };

  # No distro boot: kernelParams go into boot.scr. root=fstab mounts NIXOS_SD.
  bootArgs = lib.concatStringsSep " " config.boot.kernelParams;

  bootCmd = pkgs.writeText "onecloud-boot.cmd" ''
    # bootdev is set by multi-boot (eMMC/USB); default to SD. `test -z` is broken here.
    if test -n "''${bootdev}"; test $? != 0; then
    	setenv bootdev "mmc 0:1"
    fi

    echo "NixOS: booting from ''${bootdev}"
    fatload ''${bootdev} 0x20800000 /uImage
    fatload ''${bootdev} 0x22000000 /uInitrd
    fatload ''${bootdev} 0x21800000 /dtb/meson8b-onecloud.dtb
    setenv bootargs "${bootArgs}"
    bootm 0x20800000 0x22000000 0x21800000
  '';

  bootScript = pkgs.runCommandLocal "onecloud-boot.scr" {} ''
    ${mkimage} -A arm -T script -C none -n "NixOS boot script" -d ${bootCmd} $out
  '';
in {
  options.system.build.onecloudBootFiles = lib.mkOption {
    type = lib.types.package;
    readOnly = true;
    description = ''
      uImage, uInitrd, boot.scr and dtb/meson8b-onecloud.dtb: everything the
      OneCloud U-Boot loads from the FAT partition.
    '';
  };

  config.system.build.onecloudBootFiles = pkgs.runCommandLocal "onecloud-boot-files" {} ''
    mkdir -p $out/dtb
    cp ${uImage} $out/uImage
    cp ${uInitrd} $out/uInitrd
    cp ${bootScript} $out/boot.scr
    cp ${dtb} $out/dtb/meson8b-onecloud.dtb
  '';
}
