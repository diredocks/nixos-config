{
  config,
  LT,
  ...
}: {
  virtualisation.oci-containers.containers.magpie = {
    image = "ghcr.io/yetone/magpie:latest";
    ports = ["127.0.0.1:4820:3425" "127.0.0.1:4830:3430"];
    volumes = ["magpie:/config"];
    cmd = [
      "web"
      "--addr"
      "0.0.0.0:3430"
      "--no-open"
    ];
    environment = {
      http_proxy = "http://host.containers.internal:36176";
      https_proxy = "http://host.containers.internal:36176";
    };
    extraOptions = [
      "--env=MAGPIE_WEB_KEY"
      "--network=pasta:--map-host-loopback,169.254.1.2"
    ];
    autoStart = true;
    podman.user = LT.user;
  };

  # hosts/tpm312/secrets/magpie.key
  systemd.services.podman-magpie = {
    serviceConfig.EnvironmentFile = config.age.secrets."magpie.key".path;
    restartTriggers = ["${config.age.secrets."magpie.key".file}"];
  };

  services.nginx.virtualHosts = {
    "magpie.tpm.clickfling.top" = {
      forceSSL = true;
      useACMEHost = "tpm";
      locations."/".proxyPass = "http://127.0.0.1:4830";
    };

    "gateway.tpm.clickfling.top" = {
      forceSSL = true;
      useACMEHost = "tpm";
      locations."/".proxyPass = "http://127.0.0.1:4820";
    };
  };
}
