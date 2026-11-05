# Prebuilt ophub/kernel (rk35xx/rockchip64 6.12.y), repackaged in the layout
# NixOS expects from a kernel derivation:
#   $out/Image  $out/config  $out/System.map  $out/dtbs/rockchip/*.dtb
#   $out/lib/modules/<modDirVersion>/
#
# Bump: change `version` and `hash` (nix-prefetch-url --type sha256 <url>, then
# nix hash convert --hash-algo sha256 --to sri <hash>). ophub only keeps the last
# few patch releases per series, so old URLs 404 -- keep the tarball in your own
# cache (cachix / `nix copy`) if you want old pins to stay buildable.
#
# No `dev` output: out-of-tree modules (ZFS, nvidia, ...) cannot be built
# against this kernel.
{
  lib,
  stdenvNoCC,
  fetchurl,
  runCommand,
  ...
}: let
  version = "6.12.115";
  modDirVersion = "${version}-ophub";

  # The release asset is a tarball of tarballs:
  #   boot-*.tar.gz modules-*.tar.gz dtb-<soc>-*.tar.gz header-*.tar.gz sha256sums
  src = fetchurl {
    url = "https://github.com/ophub/kernel/releases/download/kernel_stable/${version}.tar.gz";
    hash = "sha256-NTZ71fH8xL0V+FY32gBg3VgnWIvI+NYHDSHc6jFDwZA=";
  };

  # nixos/modules/config/sysctl.nix greps the kernel's .config
  configfile = runCommand "linux-ophub-${version}.config" {} ''
    tar -xzf ${src}
    tar -xzOf ${version}/boot-${modDirVersion}.tar.gz config-${modDirVersion} > $out
  '';
in
  stdenvNoCC.mkDerivation {
    pname = "linux-ophub";
    inherit version;

    inherit src;
    sourceRoot = version;

    dontConfigure = true;
    dontBuild = true;
    dontFixup = true; # prebuilt: no strip / patchelf / broken-symlink check

    installPhase = ''
      runHook preInstall

      mkdir -p $out/dtbs/rockchip $out/lib/modules boot

      # vmlinuz-* is already an uncompressed arm64 Image (EFI stub), which is
      # what U-Boot's booti wants and what NixOS calls `Image` on aarch64.
      tar -xf boot-${modDirVersion}.tar.gz -C boot
      install -Dm644 boot/vmlinuz-${modDirVersion}    $out/Image
      install -Dm644 boot/config-${modDirVersion}     $out/config
      install -Dm644 boot/System.map-${modDirVersion} $out/System.map

      tar -xf modules-${modDirVersion}.tar.gz -C $out/lib/modules --no-same-owner --no-same-permissions
      # dangling symlink into ophub's build tree
      rm -f $out/lib/modules/${modDirVersion}/build $out/lib/modules/${modDirVersion}/source
      # nixpkgs' module aggregator expects this file to exist
      touch $out/lib/modules/${modDirVersion}/modules.cer

      tar -xf dtb-rockchip-${modDirVersion}.tar.gz -C $out/dtbs/rockchip --no-same-owner --no-same-permissions

      # fail at build time, not at boot
      test -f $out/dtbs/rockchip/rk3399-tpm312.dtb
      test -f $out/lib/modules/${modDirVersion}/modules.dep

      runHook postInstall
    '';

    passthru = {
      inherit modDirVersion configfile;
      target = "Image";
      baseVersion = version;
      kernelOlder = lib.versionOlder version;
      kernelAtLeast = lib.versionAtLeast version;
      buildDTBs = true;
      # NixOS skips its `requiredKernelConfig` assertions for kernels that have
      # `features` (it assumes nixpkgs kernels).
      features = {};
      # Same interface as nixpkgs' kernel.config (isYes/isSet/...), backed by a
      # static copy of ophub's .config so no import-from-derivation is needed.
      config = let
        opts = import ./linux-ophub-config.nix;
        get = o: opts.${lib.removePrefix "CONFIG_" o} or null;
      in {
        getValue = get;
        isSet = o: get o != null;
        isYes = o: get o == "y";
        isNo = o: get o == "n";
        isModule = o: get o == "m";
        isEnabled = o: get o == "y" || get o == "m";
        isDisabled = o: get o == null || get o == "n";
      };
      isZen = false;
      isHardened = false;
      isLibre = false;
    };

    meta = {
      description = "Prebuilt ophub Linux kernel for Rockchip boards";
      homepage = "https://github.com/ophub/kernel";
      license = lib.licenses.gpl2Only;
    };
  }
