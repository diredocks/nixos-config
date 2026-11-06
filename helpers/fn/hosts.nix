{
  lib,
  tags,
  constants,
  keys,
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
        inherit tags constants keys hostsBase;
        name = n;
      };
    }).config
) (builtins.readDir hostsBase)
