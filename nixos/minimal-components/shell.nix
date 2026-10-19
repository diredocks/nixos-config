{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  programs.zsh.enable = true;
  users.users.leo.shell = pkgs.zsh;
}
