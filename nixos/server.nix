{
  inputs,
  LT,
  ...
}: {
  imports =
    [
      "${inputs.nixpkgs}/nixos/modules/profiles/headless.nix"
      "${inputs.nixpkgs}/nixos/modules/profiles/minimal.nix"
    ]
    ++ LT.ls ./minimal-apps
    ++ LT.ls ./minimal-components
    ++ LT.ls ./server-apps;
}
