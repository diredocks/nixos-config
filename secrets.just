# Rewrite agenix-rules.nix from hosts/*/host.nix + hosts/*/secrets/.
rules:
  @{ nix eval --raw .#agenixRules; echo; } > agenix-rules.nix

# Create or edit a secret.
edit host file:
  #!/usr/bin/env bash
  set -Eeuo pipefail
  host={{quote(host)}}
  file={{quote(file)}}

  [[ $host != */* && -f "hosts/$host/host.nix" ]] \
    || { echo "error: unknown host '$host'" >&2; exit 1; }

  path="hosts/$host/secrets/$file"

  if [[ ! -s $path ]]; then
    # A placeholder seeds the rules entry, but `agenix -e` chokes on empty files.
    mkdir -p -- "hosts/$host/secrets"
    : > "$path"
    git add -N -- "$path"
    just secrets rules
    rm -f -- "$path"
  fi

  nix run .#agenix -- -e "$path"

check:
  nix run .#agenix -- -c

# Re-encrypt every secret with the current rules.
rekey: rules
  nix run .#agenix -- -r
