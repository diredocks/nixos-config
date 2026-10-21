{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  bootFiles = config.system.build.onecloudBootFiles;
in {
  imports = [
    (modulesPath + "/profiles/base.nix")
    (modulesPath + "/installer/sd-card/sd-image.nix")
  ];

  # Vendor U-Boot loads boot.scr from FAT (multi-boot); dd to SD card.
  image.baseName = "nixos-sd-image-onecloud";

  # SD only, no bootloader here. For eMMC use ./burn-image.nix; dd'ing this
  # to eMMC bricks the box (overwrites vendor preloader/U-Boot).
  #
  # `firmwareSize` 256 MiB must match the `boot` partition in the burn U-Boot's store table.
  sdImage = {
    firmwarePartitionOffset = 16;
    firmwareSize = 256;
    populateFirmwareCommands = ''
      cp -r ${bootFiles}/. firmware/
    '';
    populateRootCommands = ''
      mkdir -p ./files/boot/firmware
    '';
    postBuildCommands = "";
  };

  # Mount firmware (upstream `noauto`) to keep it in sync from NixOS.
  fileSystems."/boot/firmware".options = lib.mkForce ["nofail" "fmask=0077" "dmask=0077"];

  systemd.services.onecloud-boot-files = {
    description = "Copy the current NixOS generation into the OneCloud FAT boot partition";
    wantedBy = ["multi-user.target"];
    after = ["local-fs.target"];
    unitConfig.RequiresMountsFor = "/boot/firmware";
    path = [pkgs.coreutils pkgs.diffutils];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      set -eu

      # Skip unchanged files.
      sync_file() {
        if ! cmp -s "$1" "$2"; then
          install -m 0644 "$1" "$2"
          echo "updated $2"
        fi
      }

      install -d -m 0755 /boot/firmware/dtb
      sync_file ${bootFiles}/uImage /boot/firmware/uImage
      sync_file ${bootFiles}/uInitrd /boot/firmware/uInitrd
      sync_file ${bootFiles}/boot.scr /boot/firmware/boot.scr
      sync_file ${bootFiles}/dtb/meson8b-onecloud.dtb /boot/firmware/dtb/meson8b-onecloud.dtb
    '';
  };
}
