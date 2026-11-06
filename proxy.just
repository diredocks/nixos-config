set:
  #!/usr/bin/env bash
  set -euo pipefail
  : "${https_proxy:?https_proxy is not set}"
  sudo mkdir -p /run/systemd/system/nix-daemon.service.d
  printf '[Service]\nEnvironment="http_proxy=%s"\nEnvironment="https_proxy=%s"\n' "$https_proxy" "$https_proxy" | \
  sudo tee /run/systemd/system/nix-daemon.service.d/override.conf > /dev/null
  sudo systemctl daemon-reload
  sudo systemctl restart nix-daemon

unset:
  #!/usr/bin/env bash
  set -euo pipefail
  sudo rm -f /run/systemd/system/nix-daemon.service.d/override.conf
  sudo systemctl daemon-reload
  sudo systemctl restart nix-daemon
