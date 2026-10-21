# No mainline U-Boot for TPM312; ophub blobs (0x40/0x4000/0x6000, fit in 16 MiB gap).
{
  lib,
  stdenvNoCC,
  fetchurl,
}: let
  rev = "b08178cdbf200214514dc7c322cc664fd67d929e";

  blob = file: hash:
    fetchurl {
      name = "tpm312-${file}";
      url = "https://raw.githubusercontent.com/ophub/u-boot/${rev}/u-boot/rockchip/tpm312/${file}";
      inherit hash;
    };
in
  stdenvNoCC.mkDerivation {
    pname = "uboot-tpm312";
    # Version reported by the binary itself.
    version = "2024.10-rc2";

    dontUnpack = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp ${blob "idbloader.bin" "sha256-JpSQvz1RVS7cbn0MPPuuYKHlr9adR/pCrIUGPqrMMhY="} $out/idbloader.bin
      cp ${blob "uboot.img" "sha256-FoJc21zb31eU3kfVBemFxsqx/d4MR2WQHx/yhQSLb1g="} $out/uboot.img
      cp ${blob "trust.bin" "sha256-XeobTtLllCaGcCpDlLty0xXk/Nz3MeLCv+4lC/vq1oQ="} $out/trust.bin

      runHook postInstall
    '';

    meta = {
      description = "U-Boot bootloader blobs for the Rockchip RK3399 TPM312 board";
      homepage = "https://github.com/ophub/u-boot";
      license = lib.licenses.gpl2Plus;
      # Arch-independent blobs; leave `platforms` unset for `nix flake check` on x86_64.
    };
  }
