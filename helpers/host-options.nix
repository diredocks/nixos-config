{
  lib,
  config,
  hostsBase,
  name,
  ...
}: let
  diskoFile = hostsBase + "/${name}/hardware/disko.nix";
in {
  options = {
    name = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = name;
    };
    system = lib.mkOption {
      type = lib.types.str;
      default = "x86_64-linux";
    };
    tags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
    hasTag = lib.mkOption {
      readOnly = true;
      default = tag: builtins.elem tag config.tags;
    };
    stateVersion = lib.mkOption {
      type = lib.types.str;
    };
    homeStateVersion = lib.mkOption {
      type = lib.types.str;
    };
    withDisko = lib.mkOption {
      type = lib.types.bool;
      default = builtins.pathExists diskoFile;
    };
  };
}
