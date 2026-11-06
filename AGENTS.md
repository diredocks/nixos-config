# AGENTS.md

NixOS flake (flake-parts) for `leo`'s machines. Deploy via `deploy-rs`, secrets via `agenix`.

## Repository structure

```
flake.nix              # inputs + flake-parts entrypoint
flake-modules/         # flake outputs
  nixos-configurations.nix  # builds every host, picks role from tags
  deploy.nix                # deploy-rs nodes (servers)
  packages.nix              # custom pkgs + per-host disk/sd images
  secrets.nix               # flake.agenixRules generator
helpers/               # LT: shared library injected into every module
  constants.nix        # LT.user, LT.userHome, LT.tags
  keys.nix             # user SSH public keys (login + secret decryption)
  host-options.nix     # schema for each host.nix
  fn/hosts.nix         # evaluates all hosts/*/host.nix -> LT.hosts
  fn/ls.nix            # LT.ls <dir>: list .nix files in a dir
  fn/secrets.nix       # secret auto-discovery
  default.nix          # assembles the above into LT
hosts/<name>/          # one dir per machine
  host.nix             # metadata: system, tags, stateVersion, sshHostKeys, trustedUsers
  configuration.nix    # host-specific settings + hardware imports
  hardware/            # boot.nix / disko.nix / hardware-configuration.nix
  secrets/             # this host's ciphertext + optional default.nix overrides
agenix-rules.nix       # GENERATED, `just secrets rules`
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
justfile               # rebuild/deploy/update/format commands
  secrets.just         # `just secrets <rules|edit|check|rekey>` module
  proxy.just           # `just proxy <set|unset>` module
```

## What to do and how

**Add a host.** Create `hosts/<name>/host.nix` and `configuration.nix`; only `host.nix` needs metadata:

```nix
{...}: {
  system = "x86_64-linux";       # default
  tags = ["server"];              # "client" | "server" | none -> minimal
  stateVersion = "25.05";
  homeStateVersion = "25.05";
  sshHostKeys = ["ssh-ed25519 AAAA..."];  # agenix recipient
  trustedUsers = ["leo"];                 # default: [LT.user]
}
```

The role module is auto-selected from tags, so don't import `nixos/{client,server,minimal}.nix`. `configuration.nix` holds only host-specific settings plus `./hardware/...` imports; a `hardware/disko.nix` enables `disko`. `hosts/<name>` is picked up by `readDir`.

**Add an app/component.** Drop a `.nix` file into the right directory — `LT.ls` imports it automatically:
- Always: `nixos/minimal-apps`, `nixos/minimal-components`
- Clients: `nixos/client-components`; servers: `nixos/server-apps`
- Home-manager: `home/common-apps` (all), `home/client-apps` (clients only)

Opt-in modules (`nixos/optional-apps`, `home/optional-apps`) are **not** auto-imported — import them explicitly.

**Use `LT`.** Every module receives `LT`; prefer it over hardcoding:
- `LT.user`, `LT.userHome`, `LT.tags.{client,server}`
- `LT.ls ./dir` — import all `.nix` files in a directory
- `LT.hosts.<name>` / `LT.this` / `LT.otherHosts` / `LT.hostsWithTag <tag>`
- `LT.keys.<user>`, `LT.this.{trustedUsers,trustedUserKeys,trustedKeys}`

**Secrets.** A host's `trustedUsers` grants both SSH login and decryption; ciphertext lives in `hosts/<name>/secrets/` and needs no declaration at the usage site:

```nix
let secret = config.age.secrets."magpie.key"; in {
  systemd.services.podman-magpie.serviceConfig.EnvironmentFile = secret.path;
}
```

- Any regular file in `hosts/<name>/secrets/` (not `*.nix`/`*.md`) becomes `config.age.secrets."<file name>"`.
- `owner`/`group`/`mode`/`path`/`symlink` overrides go in `hosts/<name>/secrets/default.nix` (imported implicitly).
- Recipients = `trustedUsers` keys (`helpers/keys.nix`) + the host's `sshHostKeys`. After changing either, or adding a file: `just secrets rekey` (regenerates `agenix-rules.nix` from the repo root, then re-encrypts); `just secrets check` verifies.
- Never commit plaintext secrets.

**Custom package.** Drop `pkgs/<name>.nix` — auto-imported as `pkgs.<name>` and exposed by the overlay.

## Commands

```sh
just switch / boot
just deploy [host]
just update
just fmt
just secrets rekey
just secrets check
just secrets edit hosts/<name>/secrets/<file>
just proxy set / unset
```

Build/check before claiming success: `nix build .#nixosConfigurations.<host>.config.system.build.toplevel` (or `nix eval ...toplevel.drvPath` for eval-only). Format with `nix fmt .`.
