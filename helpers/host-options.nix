{
  lib,
  config,
  ...
} @ args: {
  options = {
    name = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = args.name;
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
      default = false;
    };
  };
}
