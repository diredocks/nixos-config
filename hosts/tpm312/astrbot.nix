{
  config,
  LT,
  ...
}: let
  dataDir = "/mnt/data/astrbot";
  containerUser = LT.user;
in {
  systemd.tmpfiles.rules = [
    "d ${dataDir} 0755 ${containerUser} users -"
    "d ${dataDir}/data 0755 ${containerUser} users -"
  ];

  virtualisation.oci-containers.containers.astrbot = {
    image = "docker.io/soulter/astrbot:latest";
    hostname = "astrbot";
    ports = ["127.0.0.1:6185:6185" "127.0.0.1:6199:6199"];
    volumes = [
      "${dataDir}/data:/AstrBot/data"
      "/etc/localtime:/etc/localtime:ro"
    ];
    environment = {
      TZ = config.time.timeZone;
      http_proxy = "http://host.containers.internal:36176";
      https_proxy = "http://host.containers.internal:36176";
    };
    extraOptions = ["--network=pasta:--map-host-loopback,169.254.1.2"];
    podman.user = containerUser;
    autoStart = true;
  };

  # forgot the dashboard password:
  #   podman exec -it astrbot astrbot password
  services.nginx.virtualHosts."astrbot.tpm.clickfling.top" = {
    forceSSL = true;
    useACMEHost = "tpm";

    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:6185";
        proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 100m;
          proxy_read_timeout 86400s;
          proxy_send_timeout 86400s;
          add_header Cache-Control "no-store, no-cache, must-revalidate" always;
          proxy_no_cache 1;
          proxy_cache_bypass 1;
        '';
      };

      "/assets/" = {
        proxyPass = "http://127.0.0.1:6185";
        extraConfig = ''
          expires 1y;
          add_header Cache-Control "public, max-age=31536000, immutable" always;
        '';
      };
    };
  };
}
