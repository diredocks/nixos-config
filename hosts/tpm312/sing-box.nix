{
  config,
  pkgs,
  ...
}: {
  services.sing-box = {
    enable = true;
    settingsFile = config.age.secrets.tpm-sb-conf.path;
  };

  systemd.services.sing-box.restartTriggers = ["${config.age.secrets.tpm-sb-conf.file}"];
  age.secrets.tpm-sb-conf.file = ../../secrets/tpm-sb-config.json;

  environment.systemPackages = [pkgs.sing-box];
}
