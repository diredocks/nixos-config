# AGENTS.md

NixOS flake (flake-parts) for `leo`'s machines. Deploy via `deploy-rs`, secrets via `agenix`.

## Repository structure

```
flake.nix              # inputs + flake-parts entrypoint
flake-modules/         # the flake's outputs
  nixos-configurations.nix  # builds every host, picks role from tags
  deploy.nix                # deploy-rs nodes (servers)
  packages.nix              # custom pkgs + per-host disk/sd images
helpers/               # LT: shared library injected into every module
  constants.nix        # LT.user, LT.userHome, LT.tags
  host-options.nix     # schema for each host.nix
  fn/hosts.nix         # evaluates all hosts/*/host.nix -> LT.hosts
  fn/ls.nix            # LT.ls <dir>: list .nix files in a dir
  default.nix          # assembles the above into LT
hosts/<name>/          # one dir per machine
  host.nix             # metadata: system, tags, stateVersion, withDisko
  configuration.nix    # host-specific settings + hardware imports
  hardware/            # boot.nix / disko.nix / hardware-configuration.nix
nixos/                 # system-level modules
  minimal.nix client.nix server.nix   # role entrypoints
  minimal-apps/ minimal-components/    # always-on base
  client-components/ server-apps/      # role-specific
  optional-apps/                       # opt-in, imported by a host config
home/                  # home-manager modules
  client.nix none.nix  # entrypoint chosen by role
  common-apps/ client-apps/ optional-apps/
pkgs/                  # custom packages (auto-added to overlay)
overlays/default.nix   # additions (pkgs/) + modifications
secrets/               # agenix secrets + public keys
justfile               # rebuild/deploy/update/format commands
```

## What to do and how

**Add a host.** Create `hosts/<name>/host.nix` and `configuration.nix`. Only `host.nix` needs metadata:

```nix
{...}: {
  system = "x86_64-linux";       # default
  tags = ["server"];              # "client" | "server" | none -> minimal
  stateVersion = "25.05";
  homeStateVersion = "25.05";
  withDisko = true;               # optional, enables disko
}
```

The role module is auto-selected from tags (`flake-modules/nixos-configurations.nix`), so don't import `nixos/{client,server,minimal}.nix` yourself. `configuration.nix` should hold only host-specific settings plus `./hardware/...` imports. `hosts/<name>` is picked up automatically by `readDir`.

**Add an app/component.** Drop a `.nix` file into the right directory — it is imported automatically by `LT.ls`:
- Always on every host: `nixos/minimal-apps`, `nixos/minimal-components`
- Clients only: `nixos/client-components`; servers only: `nixos/server-apps`
- Home-manager: `home/common-apps` (all), `home/client-apps` (clients only)

Opt-in modules (`nixos/optional-apps`, `home/optional-apps`) are **not** auto-imported — import them explicitly from a host's `configuration.nix` (system) or a home module.

**Use `LT`.** Every module receives `LT` via specialArgs; prefer it over hardcoding:
- `LT.user`, `LT.userHome`, `LT.tags.{client,server}`
- `LT.ls ./dir` — import all `.nix` files in a directory
- `LT.hosts.<name>` / `LT.this` / `LT.otherHosts` — host metadata
- `LT.hostsWithTag <tag>` / `LT.hostsWithoutTag <tag>`

**Secrets.** Add the file under `secrets/`, declare its recipients in `secrets/secrets.nix` (public keys come from `secrets/ssh-keys-pub.nix`), then reference it with `age.secrets.<name>.file`. Never commit plaintext secrets.

**Custom package.** Drop `pkgs/<name>.nix` — it is auto-imported as `pkgs.<name>` and exposed to all hosts by the overlay.

## Commands

```sh
just switch      # nixos-rebuild switch --flake .
just boot        # nixos-rebuild boot --flake .
just deploy      # deploy-rs to all server nodes
just update      # nix flake update
just fmt         # nix fmt . (alejandra)
```

Build/check before claiming success: `nix build .#nixosConfigurations.<host>.config.system.build.toplevel` or `nix flake check`. Format Nix code with `nix fmt .` (alejandra style: 2-space indent).
