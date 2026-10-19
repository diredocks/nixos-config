{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  xdg.configFile."inputactions/config.yaml".source = ./inputactions.yml;
}
