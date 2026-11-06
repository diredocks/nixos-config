{
  config,
  pkgs,
  ...
}: let
  # hosts/tpm312/secrets/tpm-sb-config.json
  secret = config.age.secrets."tpm-sb-config.json";
in {
  services.sing-box = {
    enable = true;
    settingsFile = secret.path;
  };

  systemd.services.sing-box.restartTriggers = ["${secret.file}"];

  environment.systemPackages = [pkgs.sing-box];
}
