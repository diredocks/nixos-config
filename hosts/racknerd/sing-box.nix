{
  config,
  pkgs,
  ...
}: let
  # hosts/racknerd/secrets/racknerd-sb-config.json
  secret = config.age.secrets."racknerd-sb-config.json";
in {
  services.sing-box = {
    enable = true;
    settingsFile = secret.path;
  };

  systemd.services.sing-box.restartTriggers = ["${secret.file}"];

  environment.systemPackages = [pkgs.sing-box];
}
