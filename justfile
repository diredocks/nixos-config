default: boot

boot:
  nixos-rebuild boot --flake . --sudo --ask-sudo-password

switch:
  nixos-rebuild switch --flake . --sudo --ask-sudo-password

# just deploy              -> all nodes, switch now
# just deploy tpm312        -> one host, switch now
# just deploy tpm312 --boot -> one host, activate on next boot
deploy host="" mode="switch":
  nix run nixpkgs#deploy-rs -- -s {{ if host == "" { "." } else { ".#" + host } }} {{ if mode == "switch" { "" } else if mode == "boot" { "--boot" } else { mode } }}

update:
  nix flake update

gc:
  sudo nix store gc --debug
  sudo nix-collect-garbage --delete-old
  nix-collect-garbage --delete-old

fmt:
  nix fmt .

set-proxy:
  #!/usr/bin/env bash
  set -euo pipefail
  : "${https_proxy:?https_proxy is not set}"
  sudo mkdir -p /run/systemd/system/nix-daemon.service.d
  printf '[Service]\nEnvironment="http_proxy=%s"\nEnvironment="https_proxy=%s"\n' "$https_proxy" "$https_proxy" | \
  sudo tee /run/systemd/system/nix-daemon.service.d/override.conf > /dev/null
  sudo systemctl daemon-reload
  sudo systemctl restart nix-daemon

unset-proxy:
  #!/usr/bin/env bash
  set -euo pipefail
  sudo rm -f /run/systemd/system/nix-daemon.service.d/override.conf
  sudo systemctl daemon-reload
  sudo systemctl restart nix-daemon
