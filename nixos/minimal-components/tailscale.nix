{
  # Every host joins the tailnet; `sshd.nix` allows root login from it.
  services.tailscale.enable = true;
}
