{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  kernel = config.boot.kernelPackages.kernel;
  # kernel.dev carries the source tree for out-of-tree DTS.
  kernelSource = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/source";

  # Not upstream yet; compile vendored DTS against this kernel.
  tpm312Dtb = pkgs.deviceTree.compileDTS {
    name = "rk3399-tpm312.dtb";
    dtsFile = ./rk3399-tpm312.dts;
    includePaths = [
      "${kernelSource}/arch/arm64/boot/dts/rockchip"
      "${kernelSource}/scripts/dtc/include-prefixes"
    ];
  };
in {
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_6_12;
  boot.kernelParams = ["earlycon" "console=ttyS2,1500000" "consoleblank=0"];

  # Single dtb forces explicit `FDT` line, avoids wrong rk3399 dtb.
  hardware.deviceTree = {
    enable = true;
    dtbSource = pkgs.runCommand "rk3399-tpm312-dtbs" {} ''
      mkdir -p $out/rockchip
      cp ${tpm312Dtb} $out/rockchip/rk3399-tpm312.dtb
    '';
    name = "rockchip/rk3399-tpm312.dtb";
  };
}
