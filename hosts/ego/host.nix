{...}: {
  system = "aarch64-linux";
  tags = ["client"];
  stateVersion = "26.11";
  homeStateVersion = "26.11";

  # Filled in after the first install: `cat /etc/ssh/ssh_host_ed25519_key.pub`.
  sshHostKeys = [];
}
