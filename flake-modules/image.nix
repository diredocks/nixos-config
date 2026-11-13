{
  self,
  inputs,
  ...
}: let
  lib = inputs.nixpkgs.lib;

  # LT without a nixosConfiguration: this image is not a host, and the modules
  # it uses only read host metadata from LT (user, keys, trustedUsers).
  LT = import ../helpers {
    inherit inputs lib self;
    hostName = "ego";
  };

  # The image is an aarch64 system, but it is built on the x86_64 workstation:
  # the disko builder then runs its install VM on the native platform and
  # reaches the aarch64 tools through binfmt, instead of emulating a whole
  # aarch64 machine. That is also why the output is filed under
  # packages.x86_64-linux -- the artifact is aarch64, the build is not.
  buildPkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;

  # Deliberately not the ego host: no desktop, no home-manager, no client apps.
  # This is only the base system that boots on the tablet, gets on the network
  # and can run `nixos-rebuild switch` to install the real configuration. It
  # shares ego's hardware modules, so the disk layout, BOE panel overlay and
  # boot setup are the same and the switch only replaces the system closure.
  # That keeps the image small enough to stream over Wi-Fi.
  bootstrap = lib.nixosSystem {
    system = "aarch64-linux";
    specialArgs = {
      inherit inputs self LT;
      outputs = self;
    };
    modules = [
      ../hosts/ego/configuration.nix
      inputs.disko.nixosModules.disko
      inputs.agenix.nixosModules.default
      ../nixos/minimal-apps/packages.nix
      ../nixos/minimal-components/nix.nix
      ../nixos/minimal-components/secrets.nix
      ../nixos/minimal-components/shell.nix
      ../nixos/minimal-components/sshd.nix
      ../nixos/minimal-components/tailscale.nix
      ../nixos/minimal-components/users.nix
      ({pkgs, ...}: {
        networking.hostName = "ego";
        system.stateVersion = LT.this.stateVersion;

        environment.systemPackages = [
          inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];

        disko = {
          # The install VM copies the bootstrap closure; 2 GiB of page cache is
          # plenty for a system this size.
          memSize = 2048;

          imageBuilder = {
            pkgs = buildPkgs;
            # The VM itself has to boot a kernel for the machine running the
            # build. Only the install tools inside it are aarch64.
            kernelPackages = buildPkgs.linuxPackages;
            enableBinfmt = true;
            # zstd comes from the builder's own package set, not the target's:
            # extraPostVM runs on the build machine, outside the VM.
            extraPostVM = ''
              ${buildPkgs.zstd}/bin/zstd --rm -T0 $out/*.raw
            '';
          };

          devices.disk.main = {
            imageName = "ego";
            # The bootstrap closure is well under 2 GiB. The free tail past the
            # layout is what the tablet's much larger disk reclaims with
            # `parted resizepart` after dd; the image only has to boot.
            imageSize = "6G";
          };
        };
      })
    ];
  };
in {
  # `nix build .#ego-image` produces result/ego.raw.zst. Boot the installer ISO
  # on the tablet, stream it onto the internal disk, grow the root partition,
  # then switch to the real host with
  # `nixos-rebuild switch --flake github:diredocks/nixos-config/gaokun#ego`.
  flake.packages.x86_64-linux.ego-image = bootstrap.config.system.build.diskoImages;
}
