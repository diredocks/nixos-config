{
  config,
  pkgs,
  ...
}: {
  services.sing-box = {
    enable = true;
    settingsFile = config.age.secrets.racknerd-sb-conf.path;
  };

  systemd.services.sing-box.restartTriggers = ["${config.age.secrets.racknerd-sb-conf.file}"];
  age.secrets.racknerd-sb-conf.file = ../../secrets/racknerd-sb-config.json;

  environment.systemPackages = [pkgs.sing-box];
}
