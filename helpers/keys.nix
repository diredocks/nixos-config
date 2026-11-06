# User SSH public keys — single source of truth for login and secret decryption.
# Names must match accounts from nixos/minimal-components/users.nix.
{...}: {
  leo = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFXn0O9OwDImP05mnIzbSmGdNdcg7HJ3wpdBRIi+TEwA leo@probook-nix"
  ];
}
