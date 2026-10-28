{
  inputs,
  lib,
  config,
  pkgs,
  ...
}
: {
  boot.loader.grub = {
    enable = !config.boot.isContainer;
    default = "saved";
    devices = ["/dev/vda"];
  };
  boot.initrd = {
    compressor = "zstd";
    compressorArgs = ["-19" "-T0"];
  };
  boot.kernelParams = [
    "audit=0"
    "net.ifnames=0"
  ];
  boot.initrd.availableKernelModules = [
    "virtio_net"
    "virtio_pci"
    "virtio_mmio"
    "virtio_blk"
    "virtio_scsi"
  ];
  boot.initrd.kernelModules = [
    "virtio_balloon"
    "virtio_console"
    "virtio_rng"
    "tcp_bbr"
  ];
  boot.kernel.sysctl."net.ipv4.tcp_congestion_control" = "bbr";
  boot.kernel.sysctl."net.core.default_qdisc" = "fq";
  boot.kernel.sysctl."net.ipv4.tcp_sack" = "1";
  boot.kernel.sysctl."net.ipv4.tcp_dsack" = "1";
  boot.kernel.sysctl."net.ipv4.tcp_mtu_probing" = "1";
  boot.kernel.sysctl."net.ipv4.tcp_frto" = "2";
  boot.kernel.sysctl."net.ipv4.tcp_window_scaling" = "1";
  boot.kernel.sysctl."net.core.rmem_max" = 33554432;
  boot.kernel.sysctl."net.core.wmem_max" = 33554432;
  boot.kernel.sysctl."net.ipv4.tcp_rmem" = "4096 87380 33554432";
  boot.kernel.sysctl."net.ipv4.tcp_wmem" = "4096 65536 33554432";
  boot.kernel.sysctl."net.ipv4.tcp_mem" = "786432 1048576 1572864";
  boot.kernel.sysctl."net.ipv4.tcp_keepalive_time" = 600;
  boot.kernel.sysctl."net.ipv4.tcp_keepalive_intvl" = 30;
  boot.kernel.sysctl."net.ipv4.tcp_keepalive_probes" = 5;
}
