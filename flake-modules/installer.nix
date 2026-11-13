{inputs, ...}: let
  lib = inputs.nixpkgs.lib;

  # The installer is the one output that has to exist for a fresh machine: the
  # stock NixOS minimal profile, made to boot the MateBook E Go by the gaokun3
  # module (kernel, device tree, command line), by that project's
  # nixos/installer.nix (a systemd-boot ESP carrying the device tree instead of
  # GRUB) and by hosts/ego/hardware/panel.nix, which is what the gaokun3 flake's
  # own installer lacks: the BOE panel correction for this machine.
  #
  # aarch64 only, because the kernel and the board are; on x86_64 the build
  # needs a remote builder or binfmt, as with any NixOS system of the other
  # platform.
  installer = lib.nixosSystem {
    system = "aarch64-linux";
    modules = [
      "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      inputs.gaokun3.nixosModules.gaokun3
      "${inputs.gaokun3}/nixos/installer.nix"
      ../hosts/ego/hardware/panel.nix
      ({lib, ...}: {
        # The gaokun3 firmware package is the one unfree thing the live system
        # needs; its allowUnfreePredicate is what the upstream flake uses.
        nixpkgs.config.allowUnfreePredicate = pkg: lib.getName pkg == "linux-firmware-gaokun3";
        hardware.gaokun3.enable = true;
        # profiles/base.nix turns ZFS on by default; linux-gaokun3 has no zfs or
        # cifs module and the installer needs neither to write an install.
        boot.supportedFilesystems.zfs = lib.mkForce false;
        boot.supportedFilesystems.cifs = lib.mkForce false;
        # Otherwise every image is called nixos-minimal-...; this is the part
        # that lands in the file name.
        isoImage.edition = "gaokun3";
      })
    ];
  };
in {
  # `nix build .#packages.aarch64-linux.installer-iso`, then dd
  # result/iso/nixos-gaokun3-*.iso to a USB stick. Built on an aarch64 machine
  # (or through binfmt) only.
  flake.packages.aarch64-linux.installer-iso = installer.config.system.build.isoImage;
}
