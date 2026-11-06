{LT, ...}: {
  # hosts/racknerd/secrets/infini.key
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

      secrets.pass = LT.config.age.secrets."infini.key".path;

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
