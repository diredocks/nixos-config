{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  sshKeys = import ../../secrets/ssh-keys-pub.nix;
in {
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = lib.mkDefault "no";
      PasswordAuthentication = false;
    };

    # Root only from tailscale; `Match` must stay after `settings` in the file.
    extraConfig = ''
      Match Address 100.64.0.0/10,fd7a:115c:a1e0::/48
        PermitRootLogin yes
    '';
  };

  # Reuse the user key, else root can't log in (no password auth).
  users.users.root.openssh.authorizedKeys.keys = lib.mkDefault [
    sshKeys.users.leo_probook-nix
  ];
}
