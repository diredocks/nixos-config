{
  config,
  pkgs,
  ...
}: let
  # hosts/vmiss-la/secrets/vmiss-la-sb-config.json
  secret = config.age.secrets."vmiss-la-sb-config.json";
in {
  services.sing-box = {
    enable = true;
    settingsFile = secret.path;
  };

  systemd.services.sing-box.restartTriggers = ["${secret.file}"];

  environment.systemPackages = [pkgs.sing-box];
}
