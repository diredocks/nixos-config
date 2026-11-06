{
  lib,
  config,
  keys,
  constants,
  hostsBase,
  name,
  ...
}: let
  diskoFile = hostsBase + "/${name}/hardware/disko.nix";

  keysOf = user:
    keys.${user}
    or (throw "hosts/${name}: trustedUsers entry `${user}` has no key in helpers/keys.nix");
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
    trustedUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [constants.user];
      description = "Users trusted for SSH login and secret decryption; names from helpers/keys.nix.";
    };
    sshHostKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "The host's own SSH host public key(s), used as agenix recipients.";
    };
    secretsDir = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = "hosts/${name}/secrets";
      description = "This host's secrets directory, relative to the repo root (agenix rule keys).";
    };
    secretsPath = lib.mkOption {
      type = lib.types.path;
      readOnly = true;
      default = hostsBase + "/${name}/secrets";
      description = "Absolute path of `secretsDir`.";
    };
    trustedUserKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      readOnly = true;
      default = lib.concatMap keysOf config.trustedUsers;
      description = "Public keys of `trustedUsers`.";
    };
    trustedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      readOnly = true;
      default = config.trustedUserKeys ++ config.sshHostKeys;
      description = "agenix recipients: `trustedUserKeys` plus `sshHostKeys`.";
    };
  };
}
