{
  config,
  pkgs,
  ...
}: let
  kernel = config.boot.kernelPackages.kernel;

  kernelSource =
    pkgs.runCommand "linux-${kernel.modDirVersion}-source" {
      nativeBuildInputs = [pkgs.xz];
    } ''
      mkdir -p $out
      tar -xf ${kernel.src} -C $out --strip-components=1
    '';

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

  boot.kernelParams = ["earlycon" "console=ttyS2,1500000" "consoleblank=0"];

  hardware.deviceTree = {
    enable = true;
    dtbSource = pkgs.runCommand "rk3399-tpm312-dtbs" {} ''
      mkdir -p $out/rockchip
      cp ${tpm312Dtb} $out/rockchip/rk3399-tpm312.dtb
    '';
    name = "rockchip/rk3399-tpm312.dtb";
  };
}
