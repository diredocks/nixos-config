# Auto-imported: every `<name>.nix` here becomes `pkgs.<name>` via callPackage.
# Packages needing extra arguments go in `overrides`.
{
  pkgs,
  lib,
}: let
  overrides = {
    # example = pkgs.callPackage ./example.nix {inherit (pkgs) foo;};
  };

  isPackageFile = name: type:
    lib.hasSuffix ".nix" name
    && name != "default.nix"
    && type == "regular";

  auto = lib.mapAttrs' (
    file: _:
      lib.nameValuePair (lib.removeSuffix ".nix" file) (pkgs.callPackage (./. + "/${file}") {})
  ) (lib.filterAttrs isPackageFile (builtins.readDir ./.));
in
  auto // overrides
