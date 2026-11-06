# Rewrite agenix-rules.nix from hosts/*/host.nix + hosts/*/secrets/.
rules:
  @{ nix eval --raw .#agenixRules; echo; } > agenix-rules.nix

# `just secrets edit hosts/tpm312/secrets/magpie.key`
edit path:
  nix run .#agenix -- -e {{path}}

check:
  nix run .#agenix -- -c

# Re-encrypt every secret with the current rules.
rekey: rules
  nix run .#agenix -- -r
