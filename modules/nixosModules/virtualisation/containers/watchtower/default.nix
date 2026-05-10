{
  flake.nixosModules.containers-watchtower = {
    config,
    lib,
    ...
  }: let
    cfg = config.preferences.containers-watchtower;
  in {
    options.preferences.containers-watchtower = {
      schedule = lib.mkOption {
        type = lib.types.str;
        default = "0 0 2 * * *";
      };
      timeZone = lib.mkOption {
        type = lib.types.str;
        default = config.preferences.timeZone;
      };
      notificationIdentifier = lib.mkOption {
        type = lib.types.str;
        default = "${config.networking.hostName}";
      };
    };
    config = {
      sops.secrets.watchtower_container_secrets = {
        sopsFile = ./secrets.yml;
        restartUnits = ["docker-watchtower.service"];
      };
      virtualisation.oci-containers.containers."watchtower" = {
        image = "docker.io/nickfedor/watchtower:latest";
        environment = {
          "TZ" = cfg.timeZone;
          "WATCHTOWER_LABEL_ENABLE" = "true";
          "WATCHTOWER_ROLLING_RESTART" = "false";
          "WATCHTOWER_NOTIFICATIONS_HOSTNAME" = cfg.notificationIdentifier;
          "WATCHTOWER_SCHEDULE" = cfg.schedule;
        };
        environmentFiles = [
          config.sops.secrets.watchtower_container_secrets.path
        ];
        volumes = ["/var/run/docker.sock:/var/run/docker.sock"];
        log-driver = "journald";
      };
      zelec.dockerManager.watchtower = {
        containerNames = [
          "watchtower"
        ];
      };
    };
  };
}
