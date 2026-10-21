# Amlogic USB Burning Tool image for the OneCloud.
#
# Packs the SD image's boot/rootfs into hzyitc's eMMC-capable U-Boot
# (cf. hzyitc/armbian-onecloud CI); flash over USB, then eMMC boot works.
{
  config,
  lib,
  pkgs,
  ...
}: let
  image = config.system.build.sdImage;

  tools = with pkgs.buildPackages; [
    amlimg
    android-tools # img2simg
    coreutils
    jq
    util-linux # sfdisk
    zstd
  ];
in {
  options.system.build.burnImage = lib.mkOption {
    type = lib.types.package;
    readOnly = true;
    description = ''
      Amlogic USB Burning Tool image for the OneCloud (U-Boot + boot/rootfs).
    '';
  };

  config.system.build.burnImage =
    pkgs.runCommandLocal "${config.image.baseName}.burn.img" {
      nativeBuildInputs = tools;
    } ''
      set -euo pipefail

      work=$PWD/burn
      mkdir -p $work
      cp -r ${pkgs.uboot-onecloud}/. $work
      chmod -R u+w $work

      # SD image is a full MBR disk; split out its two partitions as-is.
      zstd -dc ${image}/${config.image.filePath} >disk.img
      partition() {
        sfdisk --json disk.img |
          jq -r ".partitiontable.partitions[$1].$2"
      }
      for part in 0 1; do
        start=$(partition $part start)
        size=$(partition $part size)
        if [ "$part" = 0 ]; then
          dd if=disk.img of=$work/boot.fat bs=512 skip=$start count=$size status=none
        else
          dd if=disk.img of=$work/rootfs.ext4 bs=512 skip=$start count=$size status=none
        fi
      done
      rm -f disk.img

      # Burning Tool takes sparse images plus `sha1sum <hash>` VERIFY files.
      img2simg $work/boot.fat $work/boot.simg
      img2simg $work/rootfs.ext4 $work/rootfs.simg
      rm -f $work/boot.fat $work/rootfs.ext4

      printf 'sha1sum %s' "$(sha1sum $work/boot.simg | cut -d' ' -f1)" >$work/boot.VERIFY
      printf 'sha1sum %s' "$(sha1sum $work/rootfs.simg | cut -d' ' -f1)" >$work/rootfs.VERIFY

      cat >>$work/commands.txt <<EOF
      PARTITION:boot:sparse:boot.simg
      VERIFY:boot:normal:boot.VERIFY
      PARTITION:rootfs:sparse:rootfs.simg
      VERIFY:rootfs:normal:rootfs.VERIFY
      EOF

      AmlImg pack $out $work
    '';
}
