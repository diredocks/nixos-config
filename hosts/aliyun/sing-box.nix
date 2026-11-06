{
  config,
  pkgs,
  ...
}: let
  # hosts/aliyun/secrets/aliyun-sb-config.json
  secret = config.age.secrets."aliyun-sb-config.json";
in {
  services.sing-box = {
    enable = true;
    settingsFile = secret.path;
  };

  systemd.services.sing-box.restartTriggers = ["${secret.file}"];

  environment.systemPackages = [pkgs.sing-box];
}
