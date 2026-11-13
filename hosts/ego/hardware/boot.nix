{lib, ...}: {
  # systemd-boot is the loader the gaokun3 device tree is tested with. The
  # firmware cannot write EFI variables (`efi=noruntime`, set by the gaokun3
  # module), so EFI-variable writes stay off and the loader installs to the
  # removable path \EFI\BOOT\BOOTAA64.EFI on the ESP mounted at /boot.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault false;
}
