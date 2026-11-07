{
  pkgs,
  LT,
  ...
}: let
  dataDir = "${LT.userHome}/.local/share/vaultwarden";
  remoteDir = "${LT.userHome}/remote/vaultwarden";
in {
  systemd.services.vaultwarden-backup = {
    description = "Backup vaultwarden";
    path = with pkgs; [sqlite zstd gnutar coreutils util-linux];
    environment = {
      DATA_DIR = dataDir;
      REMOTE_DIR = remoteDir;
    };
    script = builtins.readFile ./vaultwarden-backup.sh;
    serviceConfig = {
      Type = "oneshot";
      User = LT.user;
    };
  };

  systemd.timers.vaultwarden-backup = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*-*-* 10:00:00";
      Persistent = true;
    };
  };
}
