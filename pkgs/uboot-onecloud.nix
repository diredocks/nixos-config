# eMMC-capable U-Boot for OneCloud (Amlogic S805) from hzyitc/u-boot.
# Unpacked burn image for hosts/onecloud/hardware/burn-image.nix to reuse.
{
  lib,
  stdenvNoCC,
  fetchurl,
  buildPackages,
}:
stdenvNoCC.mkDerivation {
  pname = "uboot-onecloud-burn";
  version = "build-20221028-0940";

  src = fetchurl {
    name = "onecloud-eMMC.burn.img";
    url = "https://github.com/hzyitc/u-boot/releases/download/build-20221028-0940/eMMC.burn.img";
    hash = "sha256-0z2XnSO4pgdEfFr0JLHiQAOCDn4VnlQMf0fInUXNxJE=";
  };

  dontUnpack = true;

  # AmlImg runs on the build machine; it may lack the flake overlay.
  nativeBuildInputs = [(buildPackages.callPackage ./amlimg.nix {})];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    AmlImg unpack $src $out

    runHook postInstall
  '';

  meta = {
    description = "eMMC-capable U-Boot burn image for the Xunlei OneCloud";
    homepage = "https://github.com/hzyitc/u-boot/tree/onecloud";
    license = lib.licenses.gpl2Plus;
    # Arch-independent data; only the armv7l image uses it.
  };
}
