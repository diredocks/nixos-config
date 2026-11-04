{LT, ...}: {
  virtualisation.podman.enable = true;
  virtualisation.oci-containers.backend = "podman";
  users.users.${LT.user}.linger = true;
}
