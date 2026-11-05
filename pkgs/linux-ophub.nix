# Prebuilt ophub/kernel (rk35xx/rockchip64 6.12.y), repackaged into the layout
# NixOS expects: Image / config / System.map / dtbs / lib/modules. No `dev`
# output, so out-of-tree modules cannot be built against it.
#
# Bump: update `version` and `hash` (`nix-prefetch-url --type sha256 <url>`, then
# `nix hash convert --hash-algo sha256 --to sri <hash>`), then refresh
# pkgs/linux-ophub/config from the same tarball -- installPhase cmp's it, so a
# stale copy fails the build:
#   tar -xzf <tarball> && tar -xzOf <version>/boot-<modDirVersion>.tar.gz \
#     config-<modDirVersion> > pkgs/linux-ophub/config
# ophub keeps only the last few patch releases per series, so old URLs 404 --
# keep the tarball in your own cache (cachix / `nix copy`) to keep pins working.
{
  lib,
  stdenvNoCC,
  fetchurl,
  runCommand,
  ...
}: let
  version = "6.12.115";
  modDirVersion = "${version}-ophub";

  # tarball of tarballs: boot-*, modules-*, dtb-rockchip-*, header-*
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

      # vmlinuz-* is already the uncompressed arm64 Image that booti wants.
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
      cmp $out/config ${./linux-ophub/config}

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
      # nixpkgs' kernel.config interface, parsed from the vendored .config.
      # Reading it off the built derivation would be import-from-derivation,
      # which needs an aarch64 builder just to evaluate tpm312.
      config = let
        parseLine = line: let
          set = lib.match "CONFIG_([^=]+)=(.*)" line;
        in
          if set == null
          then null
          else {
            name = lib.elemAt set 0;
            # CONFIG_X="str" -> str
            value = lib.removeSuffix "\"" (lib.removePrefix "\"" (lib.elemAt set 1));
          };
        opts = lib.listToAttrs (
          lib.filter (o: o != null) (map parseLine (lib.splitString "\n" (builtins.readFile ./linux-ophub/config)))
        );
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
