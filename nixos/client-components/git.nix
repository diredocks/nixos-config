{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;
    config = {
      init = {
        defaultBranch = "main";
      };
      user = {
        name = "diredocks";
        email = "26994007+diredocks@users.noreply.github.com";
      };
    };
  };
}
