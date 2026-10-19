{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  virtualisation.libvirtd.enable = true;
  virtualisation.incus.enable = true;
  networking.nftables.enable = true;
  networking.firewall.trustedInterfaces = ["incusbr0" "virbr0"];
  programs.virt-manager.enable = true;
  users.users.leo.extraGroups = ["libvirtd" "incus-admin"];
}
