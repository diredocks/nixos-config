{lib, ...}: let
  # Regular non-Nix files are secrets; ciphertext keeps its name.
  isSecretFile = name: type: let
    ignored =
      lib.hasPrefix "." name
      || lib.any (suffix: lib.hasSuffix suffix name) [".nix" ".md"];
  in
    type == "regular" && !ignored;

  discover = dir:
    if builtins.pathExists dir
    then lib.filterAttrs isSecretFile (builtins.readDir dir)
    else {};
in {
  inherit discover;

  mk = dir:
    lib.mapAttrs (name: _: {
      file = dir + "/${name}";
    }) (discover dir);
}
