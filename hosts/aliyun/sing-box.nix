{
  config,
  pkgs,
  ...
}: {
  services.sing-box = {
    enable = true;
    settingsFile = config.age.secrets.aliyun-sb-conf.path;
  };

  systemd.services.sing-box.restartTriggers = ["${config.age.secrets.aliyun-sb-conf.file}"];
  age.secrets.aliyun-sb-conf.file = ../../secrets/aliyun-sb-config.json;

  environment.systemPackages = [pkgs.sing-box];
}
