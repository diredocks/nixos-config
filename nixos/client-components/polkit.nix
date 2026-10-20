{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  security.polkit = {
    enable = true;
    enablePkexecWrapper = true;
  };
}
