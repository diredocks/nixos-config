{
  lib,
  tags,
  constants,
  hostsBase,
  ...
}:
lib.mapAttrs (
  n: _:
    (lib.evalModules {
      modules = [
        ../host-options.nix
        (hostsBase + "/${n}/host.nix")
      ];
      specialArgs = {
        inherit tags constants hostsBase;
        name = n;
      };
    }).config
) (builtins.readDir hostsBase)
