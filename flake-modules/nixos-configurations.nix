{
  self,
  inputs,
  ...
}: let
  inherit (inputs.nixpkgs) lib;

  mkLT = name:
    import ../helpers {
      inherit inputs self lib;
      inherit (self.nixosConfigurations."${name}") config pkgs;
    };

  # Role is derived from the host's tags so configuration.nix only holds
  # host-specific settings and hardware imports.
  roleModule = LT: host:
    if host.hasTag LT.tags.client
    then ../nixos/client.nix
    else if host.hasTag LT.tags.server
    then ../nixos/server.nix
    else ../nixos/minimal.nix;

  mkHost = name: let
    LT = mkLT name;
    host = LT.hosts."${name}";
  in
    lib.nixosSystem {
      system = host.system;
      specialArgs = {
        inherit inputs self LT;
        outputs = self;
      };
      modules =
        [
          (roleModule LT host)
          (../hosts + "/${name}/configuration.nix")
          {
            networking.hostName = lib.mkForce name;
            system.stateVersion = host.stateVersion;
          }
        ]
        ++ lib.optional host.withDisko inputs.disko.nixosModules.disko
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
    lib.mapAttrs (n: _: mkHost n) (builtins.readDir ../hosts);
}
