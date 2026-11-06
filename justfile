default: boot

mod proxy
mod secrets

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
