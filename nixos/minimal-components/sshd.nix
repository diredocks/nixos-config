{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = lib.mkDefault "no";
      PasswordAuthentication = false;
    };
  };
}
