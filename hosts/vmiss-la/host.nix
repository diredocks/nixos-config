{...}: {
  system = "x86_64-linux";
  tags = ["server"];
  stateVersion = "25.05";
  homeStateVersion = "25.05";

  sshHostKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL9stKvE4KD2jYb2mBYKt9gVmNi76tKjn9YWpjpkDvk/"
  ];
}
