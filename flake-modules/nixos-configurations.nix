{
  self,
  inputs,
  ...
}: let
  LT = import ../helpers {
    inherit inputs self;
    inherit (inputs.nixpkgs) lib;
  };

  # Role is derived from the host's tags so configuration.nix only holds
  # host-specific settings and hardware imports.
  roleModule = host:
    if host.hasTag LT.tags.client
    then ../nixos/client.nix
    else if host.hasTag LT.tags.server
    then ../nixos/server.nix
    else ../nixos/minimal.nix;

  makeConfig = name: let
    host = LT.hosts."${name}";
  in
    inputs.nixpkgs.lib.nixosSystem {
      system = host.system;
      specialArgs = {
        inherit inputs self LT;
        outputs = self;
      };
      modules =
        [
          (roleModule host)
          (../hosts + "/${name}/configuration.nix")
          {
            networking.hostName = inputs.nixpkgs.lib.mkForce name;
            system.stateVersion = host.stateVersion;
          }
        ]
        ++ inputs.nixpkgs.lib.optional host.withDisko inputs.disko.nixosModules.disko
        ++ [
          inputs.home-manager.nixosModules.home-manager
          inputs.agenix.nixosModules.default
          ({pkgs, ...}: {
            environment.systemPackages = [
              inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
            ];
          })
        ];
    };
in {
  flake.nixosConfigurations =
    inputs.nixpkgs.lib.mapAttrs (n: _: makeConfig n) (builtins.readDir ../hosts);
}
