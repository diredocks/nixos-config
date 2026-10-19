{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  disabledModules = [
    "services/networking/tailscale-derper.nix"
  ];

  options = {
    services.tailscale.derper = {
      enable = mkEnableOption "Tailscale DERP server";

      envFile = mkOption {
        type = types.path;
        description = ''
          Path to a systemd EnvironmentFile that provides all DERP_* variables.
        '';
      };

      package = mkPackageOption pkgs ["tailscale" "derper"] {};
    };
  };

  config = let
    cfg = config.services.tailscale.derper;
  in
    mkIf cfg.enable {
      systemd.services.tailscale-derper = {
        serviceConfig = {
          EnvironmentFile = cfg.envFile;
          ExecStart =
            "${lib.getExe' cfg.package "derper"} -c /var/lib/derper/derper.key"
            + " -hostname \${DERP_DOMAIN}"
            + " -certmode \${DERP_CERT_MODE}"
            + " -certdir \${DERP_CERT_DIR}"
            + " -a \${DERP_ADDR}"
            + " -http-port \${DERP_HTTP_PORT}"
            + " -stun \${DERP_STUN}"
            + " -stun-port \${DERP_STUN_PORT}"
            + " -verify-clients \${DERP_VERIFY_CLIENTS}";
          DynamicUser = true;
          Restart = "always";
          RestartSec = "5sec"; # don't crash loop immediately
          StateDirectory = "derper";
          Type = "simple";

          CapabilityBoundingSet = [""];
          DeviceAllow = null;
          LockPersonality = true;
          NoNewPrivileges = true;
          MemoryDenyWriteExecute = true;
          PrivateDevices = true;
          PrivateUsers = true;
          ProcSubset = "pid";
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_UNIX"
          ];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          SystemCallArchitectures = "native";
          SystemCallFilter = ["@system-service"];
        };
        wantedBy = ["multi-user.target"];
      };
    };
}
