{...}: {
  # Whole internal disk: a 1 GiB ESP for systemd-boot and one btrfs pool with the
  # @/@home/@nix subvolumes. `fileSystems` come from this file (disko's
  # enableConfig default), so there is no generated hardware-configuration.nix
  # for this host.
  #
  # `disko` writes the partition table, so the layout is changed the same way it
  # is created: edit here, re-run disko, reinstall. The device is the internal
  # NVMe of the MateBook E Go; `--disk main /dev/nvme0n1` overrides it at run
  # time if it ever enumerates differently.
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/nvme0n1";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = ["fmask=0077" "dmask=0077"];
          };
        };
        nixos = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = ["-L" "nixos" "-f"];
            subvolumes = {
              "@" = {
                mountpoint = "/";
                mountOptions = ["compress=zstd" "noatime"];
              };
              "@home" = {
                mountpoint = "/home";
                mountOptions = ["compress=zstd" "noatime"];
              };
              "@nix" = {
                mountpoint = "/nix";
                mountOptions = ["compress=zstd" "noatime"];
              };
            };
          };
        };
      };
    };
  };
}
