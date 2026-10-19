{
  config ? {},
  pkgs ? {},
  lib ? pkgs.lib,
  inputs,
  self ? null,
  hostsBase ? ../hosts,
  ...
}: let
  call = path: lib.callPackageWith (pkgs // helpers) path {};

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
    inherit (constants) tags;

    ls = call ./fn/ls.nix;

    hosts = call ./fn/hosts.nix;
    this = hosts."${config.networking.hostName}";
    otherHosts = builtins.removeAttrs hosts [config.networking.hostName];

    hostsWithTag = tag: lib.filterAttrs (n: v: v.hasTag tag) hosts;
    hostsWithoutTag = tag: lib.filterAttrs (n: v: !(v.hasTag tag)) hosts;
  };
in
  helpers
