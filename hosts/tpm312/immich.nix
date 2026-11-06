{
  config,
  lib,
  pkgs,
  LT,
  ...
}: let
  dataDir = "/mnt/data/immich";
  uploadLocation = "${dataDir}/library";
  dbDataLocation = "${dataDir}/postgres";

  version = "v2";

  network = "immich";
  # hosts/tpm312/secrets/immich.env
  envFile = config.age.secrets."immich.env".path;
  podman = config.virtualisation.podman.package;
  containerNames = ["immich-server" "immich-redis" "immich-database"];
  containerUser = LT.user;
in {
  systemd.tmpfiles.rules = [
    "d ${dataDir} 0755 ${containerUser} users -"
    "d ${uploadLocation} 0755 ${containerUser} users -"
    "d ${dbDataLocation} 0700 ${containerUser} users -"
  ];

  virtualisation.oci-containers.containers = {
    immich-server = {
      image = "ghcr.io/immich-app/immich-server:${version}";
      hostname = "immich-server";
      networks = [network];
      environmentFiles = [envFile];
      environment = {
        # the machine-learning container is not deployed
        IMMICH_MACHINE_LEARNING_ENABLED = "false";
      };
      volumes = [
        "${uploadLocation}:/data"
        "/etc/localtime:/etc/localtime:ro"
      ];
      ports = ["127.0.0.1:2283:2283"];
      dependsOn = ["immich-redis" "immich-database"];
      extraOptions = ["--stop-timeout=60"];
      podman.user = containerUser;
      autoStart = true;
    };

    immich-redis = {
      image = "docker.io/valkey/valkey:9@sha256:546304417feac0874c3dd576e0952c6bb8f06bb4093ea0c9ca303c73cf458f63";
      hostname = "redis";
      networks = [network];
      podman.user = containerUser;
      autoStart = true;
    };

    immich-database = {
      image = "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0@sha256:bcf63357191b76a916ae5eb93464d65c07511da41e3bf7a8416db519b40b1c23";
      hostname = "database";
      networks = [network];
      environmentFiles = [envFile];
      environment = {
        POSTGRES_INITDB_ARGS = "--data-checksums";
        DB_STORAGE_TYPE = "HDD";
      };
      volumes = ["${dbDataLocation}:/var/lib/postgresql/data"];
      extraOptions = ["--shm-size=128mb"];
      podman.user = containerUser;
      autoStart = true;
    };

    # immich-machine-learning = {
    #   image = "ghcr.io/immich-app/immich-machine-learning:${version}";
    #   hostname = "immich-machine-learning";
    #   networks = [network];
    #   environmentFiles = [envFile];
    #   volumes = ["immich-model-cache:/cache"];
    #   podman.user = containerUser;
    #   autoStart = true;
    # };
  };

  systemd.services =
    {
      # oci-containers has no network option, so create it before the containers start.
      podman-network-immich = {
        description = "Create the podman network used by immich";
        wantedBy = ["multi-user.target"];
        wants = ["network-online.target" "linger-users.service"];
        after = ["network-online.target" "linger-users.service"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          User = containerUser;
          Environment = "HOME=${config.users.users.${containerUser}.home}";
          ExecStart = pkgs.writeShellScript "create-immich-network" ''
            ${podman}/bin/podman network inspect ${network} >/dev/null 2>&1 ||
              ${podman}/bin/podman network create ${network}
          '';
        };
      };
    }
    // lib.listToAttrs (map (name: {
        name = "podman-${name}";
        value = {
          after = ["podman-network-immich.service"];
          wants = ["podman-network-immich.service"];
          restartTriggers = ["${config.age.secrets."immich.env".file}"];
        };
      })
      containerNames);

  services.nginx.virtualHosts."immich.tpm.clickfling.top" = {
    forceSSL = true;
    useACMEHost = "tpm";
    locations."/" = {
      proxyPass = "http://127.0.0.1:2283";
      proxyWebsockets = true;
      extraConfig = ''
        client_max_body_size 50000M;
      '';
    };
  };
}
