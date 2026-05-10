{
  flake.nixosModules.containers-matrix-backend-call-support = {
    config,
    lib,
    ...
  }: {
    config = {
      networking.firewall = {
        allowedTCPPorts = lib.mkOptionDefault [
          # Livekit RTC TCP Port
          7881
          # TURN port
          3478
        ];
        allowedUDPPorts = lib.mkOptionDefault [
          # TURN port
          3478
        ];
        # TCP and UDP ranges for both Livekit and Coturn
        allowedTCPPortRanges = lib.mkOptionDefault [
          {
            from = 50100;
            to = 65535;
          }
        ];
        allowedUDPPortRanges = lib.mkOptionDefault [
          {
            from = 50100;
            to = 65535;
          }
        ];
      };
      sops.secrets.livekit_config = {
        sopsFile = ./secrets.yml;
        restartUnits = ["docker-livekit.service"];
      };
      sops.secrets.coturn_config = {
        sopsFile = ./secrets.yml;
        restartUnits = ["docker-coturn.service"];
      };
      sops.secrets.livekit_jwt_service_env = {
        sopsFile = ./secrets.yml;
        restartUnits = ["docker-lk-jwt-service.service"];
      };
      virtualisation.oci-containers.containers."lk-jwt-service" = {
        image = "ghcr.io/element-hq/lk-jwt-service:latest";
        environment = {
          "LIVEKIT_JWT_BIND" = ":8081";
          "LIVEKIT_URL" = "wss://livekit.timeguard.ca";
        };
        environmentFiles = [
          config.sops.secrets.livekit_jwt_service_env.path
        ];
        labels = {
          "com.centurylinklabs.watchtower.enable" = "true";
          "caddy_0" = "livekit.timeguard.ca";
          "caddy_0.@lk-jwt-service.path" = "/sfu/get* /healthz* /get_token*";
          "caddy_0.route" = "@lk-jwt-service";
          "caddy_0.route.reverse_proxy" = "{{upstreams 8081}}";
          "caddy_1" = "timeguard.ca";
          "caddy_1.header" = "Access-Control-Allow-Origin *";
          "caddy_1.respond_0" = "/.well-known/matrix/server {\"m.server\":\"matrix.timeguard.ca:443\"} 200";
          "caddy_1.respond_1" = "/.well-known/matrix/client {\"m.server\":{\"base_url\":\"https://matrix.timeguard.ca\"},\"m.homeserver\":{\"base_url\":\"https://matrix.timeguard.ca\"},\"m.identity_server\":{\"base_url\":\"https://matrix.timeguard.ca\"},\"org.matrix.msc3575.proxy\":{\"url\":\"https://matrix.timeguard.ca\"},\"org.matrix.msc4143.rtc_foci\":[{\"type\":\"livekit\",\"livekit_service_url\":\"https://livekit.timeguard.ca\"}]} 200";
          "caddy_1.respond_2" = "/.well-known/matrix/support {\"contacts\":[{\"email_address\":\"zelec@timeguard.ca\",\"matrix_id\":\"@zelec:timeguard.ca\",\"role\":\"m.role.admin\"}]} 200";
          "caddy_1.redir_0" = "/.well-known/webfinger https://webfinger.timeguard.ca/.well-known/webfinger 301";
          "caddy_1.@well-known-matchers.not.path" = "/.well-known/matrix/* /.well-known/webfinger";
          "caddy_1.redir_1" = "@well-known-matchers https://blog.timeguard.ca{uri} 302";
        };
        log-driver = "journald";
        extraOptions = [
          "--network-alias=lk-jwt-service"
          "--network=matrix-backend-call-support_livekit_internal"
          "--network=${config.preferences.containers-caddy.dockerNetworkName}"
        ];
      };
      virtualisation.oci-containers.containers."livekit" = {
        image = "docker.io/livekit/livekit-server:latest";
        cmd = ["--config" "/etc/livekit.yaml"];
        ports = [
          "7881:7881/tcp"
          "50100-50200:50100-50200/tcp"
          "50100-50200:50100-50200/udp"
        ];
        labels = {
          "com.centurylinklabs.watchtower.enable" = "true";
          "caddy_0" = "livekit.timeguard.ca";
          "caddy_0.reverse_proxy" = "{{upstreams 7880}}";
        };
        volumes = ["${config.sops.secrets.livekit_config.path}:/etc/livekit.yaml:ro"];
        log-driver = "journald";
        extraOptions = [
          "--network-alias=livekit"
          "--network=matrix-backend-call-support_livekit_internal"
          "--network=${config.preferences.containers-caddy.dockerNetworkName}"
        ];
      };
      virtualisation.oci-containers.containers."coturn" = {
        image = "docker.io/coturn/coturn:latest";
        labels = {
          "com.centurylinklabs.watchtower.enable" = "true";
        };
        volumes = ["${config.sops.secrets.coturn_config.path}:/etc/coturn/turnserver.conf:ro"];
        log-driver = "journald";
        extraOptions = ["--network=host"];
      };
      zelec.dockerManager.matrix-backend-call-support = {
        containerNames = [
          "coturn"
          "livekit"
          "lk-jwt-service"
        ];
        networkNames = [
          "livekit_internal"
        ];
      };
    };
  };
}
