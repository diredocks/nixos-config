{
  lib,
  LT,
  ...
}: let
  override = LT.this.secretsPath + "/default.nix";
in {
  imports = lib.optional (builtins.pathExists override) override;

  # One `age.secrets."<file name>"` per file in `LT.this.secretsPath`.
  age.secrets = LT.secrets.mk LT.this.secretsPath;
}
