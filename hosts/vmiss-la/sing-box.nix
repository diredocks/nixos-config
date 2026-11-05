{
  config,
  pkgs,
  ...
}: {
  services.sing-box = {
    enable = true;
    settingsFile = config.age.secrets.vmiss-la-sb-conf.path;
  };

  systemd.services.sing-box.restartTriggers = ["${config.age.secrets.vmiss-la-sb-conf.file}"];
  age.secrets.vmiss-la-sb-conf.file = ../../secrets/vmiss-la-sb-config.json;

  environment.systemPackages = [pkgs.sing-box];
}
