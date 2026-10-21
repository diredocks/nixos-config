{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware/hardware-configuration.nix
    ./hardware/boot-files.nix
    ./hardware/sd-image.nix
    ./hardware/burn-image.nix
  ];

  # networkd is lighter than NetworkManager on this 1 GiB / single-GbE box.
  networking.useDHCP = false;
  networking.firewall.enable = false;
  systemd.network.enable = true;
  systemd.network.networks.eth0 = {
    matchConfig.Name = "eth0";
    networkConfig.DHCP = "ipv4";
  };

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";

  services.openssh.settings.PermitRootLogin = "yes";

  # tcpdump pulls rdma-core man pages (pandoc/GHC, no armv7l bootstrap); skip them.
  nixpkgs.overlays = [
    (final: prev: {
      rdma-core = prev.rdma-core.override {withManPages = false;};
    })
  ];

  services.tailscale.enable = true;
  environment.systemPackages = with pkgs; [
    tailscale
  ];
}
