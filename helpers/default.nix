{
  config ? {},
  pkgs ? {},
  lib ? pkgs.lib,
  inputs,
  self ? null,
  hostsBase ? ../hosts,
  hostName ? throw "helpers: pass `hostName` to use LT.this",
  ...
}: let
  call = path: let
    result = lib.callPackageWith helpers path {};
  in
    if builtins.isAttrs result
    then removeAttrs result ["override" "overrideDerivation"]
    else result;

  helpers = rec {
    inherit
      config
      pkgs
      lib
      inputs
      self
      hostsBase
      ;

    constants = call ./constants.nix;
    inherit (constants) tags user userHome;

    ls = call ./fn/ls.nix;
    keys = call ./keys.nix;
    secrets = call ./fn/secrets.nix;

    this = hosts.${hostName};
    hosts = call ./fn/hosts.nix;
    otherHosts = builtins.removeAttrs hosts [hostName];

    hostsWithTag = tag: lib.filterAttrs (n: v: v.hasTag tag) hosts;
    hostsWithoutTag = tag: lib.filterAttrs (n: v: !(v.hasTag tag)) hosts;
  };
in
  helpers
