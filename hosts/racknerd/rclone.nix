{LT, ...}: {
  age.secrets.infini = {
    file = ../../secrets/infini.key;
    owner = LT.user;
  };

  programs.fuse.enable = true;

  home-manager.users.${LT.user}.programs.rclone = {
    enable = true;
    remotes.infini = {
      config = {
        type = "webdav";
        url = "https://gima.teracloud.jp/dav/";
        vendor = "other";
        user = "Bounce4778";
      };

      secrets.pass = LT.config.age.secrets.infini.path;

      mounts = {
        "vaultwarden" = {
          enable = true;
          mountPoint = "${LT.userHome}/remote/vaultwarden";
          options = {
            vfs-cache-mode = "writes";
            dir-cache-time = "5m";
          };
        };
      };
    };
  };
}
