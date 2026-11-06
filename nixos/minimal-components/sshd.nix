{
  lib,
  LT,
  ...
}: {
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

  users.users.${LT.user}.openssh.authorizedKeys.keys = LT.this.trustedUserKeys;
  users.users.root.openssh.authorizedKeys.keys = lib.mkDefault LT.this.trustedUserKeys;
}
