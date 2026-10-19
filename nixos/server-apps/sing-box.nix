{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  disabledModules = ["services/networking/sing-box.nix"];

  options = {
    services.sing-box = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to run sing-box server.

          Either `settingsFile` or `settings` must be specified.
        '';
      };

      package = mkPackageOption pkgs "sing-box" {};

      settingsFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        example = "/etc/sing-box/config.json";
        description = ''
          The absolute path to the configuration file.

          Either `settingsFile` or `settings` must be specified.

          See <https://sing-box.sagernet.org/configuration/>.
        '';
      };

      settings = mkOption {
        type = types.nullOr (types.attrsOf types.unspecified);
        default = null;
        example = {
          log = {
            level = "info";
            timestamp = true;
          };
          inbounds = [
            {
              type = "http";
              tag = "http-in";
              listen = "127.0.0.1";
              listen_port = 1080;
            }
          ];
          outbounds = [
            {
              type = "direct";
              tag = "direct";
            }
          ];
        };
        description = ''
          The configuration object.

          Either `settingsFile` or `settings` must be specified.

          See <https://sing-box.sagernet.org/configuration/>.
        '';
      };
    };
  };

  config = let
    cfg = config.services.sing-box;
    settingsFile =
      if cfg.settingsFile != null
      then cfg.settingsFile
      else
        pkgs.writeTextFile {
          name = "sing-box.json";
          text = builtins.toJSON cfg.settings;
          checkPhase = ''
            ${cfg.package}/bin/sing-box check -c $out
          '';
        };
  in
    mkIf cfg.enable {
      assertions = [
        {
          assertion = (cfg.settingsFile == null) != (cfg.settings == null);
          message = "Either but not both `settingsFile` and `settings` should be specified for sing-box.";
        }
      ];

      systemd.services.sing-box = {
        description = "sing-box Service";
        after = ["network.target"];
        wantedBy = ["multi-user.target"];
        script = ''
          exec "${cfg.package}/bin/sing-box" -D "$STATE_DIRECTORY" run -c "$CREDENTIALS_DIRECTORY/config.json"
        '';
        serviceConfig = {
          DynamicUser = true;
          LoadCredential = "config.json:${settingsFile}";
          StateDirectory = "sing-box";
          StateDirectoryMode = "0700";
          CapabilityBoundingSet = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE";
          AmbientCapabilities = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE";
          NoNewPrivileges = true;
          Restart = "always";
          RestartSec = 5;
        };
      };
    };
}
