{LT, ...}: {
  systemd.tmpfiles.rules = [
    "d ${LT.userHome}/.local/share/vaultwarden 0700 ${LT.user} users -"
  ];

  virtualisation.oci-containers.containers.vaultwarden = {
    image = "docker.io/vaultwarden/server:latest";
    ports = ["127.0.0.1:9273:80"];
    volumes = ["${LT.userHome}/.local/share/vaultwarden:/data"];
    autoStart = true;
    podman.user = LT.user;
    environment = {
      DOMAIN = "https://vault.clickfling.top";
      SIGNUPS_ALLOWED = "false";
      INVITATIONS_ALLOWED = "false";
    };
  };

  services.nginx.virtualHosts."vault.clickfling.top" = {
    forceSSL = true;
    enableACME = true;
    locations."/".proxyPass = "http://127.0.0.1:9273";
  };
}
