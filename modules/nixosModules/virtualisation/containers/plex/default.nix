{self, ...}: {
  flake.nixosModules.containers-plex = {
    pkgs,
    lib,
    ...
  }: let
    dockerProject = "plex";
    dockerProjectAppdata = "/opt/dockerservices/plex";
    plexMediaPath = "/media/Storage_01/media";
    timeZone = "America/Toronto";
  in {
    virtualisation.oci-containers.containers."plex" = {
      image = "lscr.io/linuxserver/plex:latest";
      environment = {
        "PUID" = "1000";
        "PGID" = "100";
        "TZ" = timeZone;
        "VERSION" = "public";
        "NVIDIA_VISIBLE_DEVICES" = "all";
        # "NVIDIA_DRIVER_CAPABILITIES" = "compute,video,utility";
      };
      volumes = [
        "${plexMediaPath}:/plex_media:rw"
        "${dockerProjectAppdata}/config/plex:/config:rw"
        "${dockerProjectAppdata}/tmp/transcode:/transcode:rw"
      ];
      labels = {
        "com.centurylinklabs.watchtower.enable" = "true";
      };
      log-driver = "journald";
      extraOptions = [
        "--device=nvidia.com/gpu=all"
        "--network=host"
      ];
    };
    virtualisation.oci-containers.containers."tautulli" = {
      image = "lscr.io/linuxserver/tautulli:latest";
      environment = {
        "PUID" = "1000";
        "PGID" = "100";
        "TZ" = timeZone;
      };
      volumes = [
        "${dockerProjectAppdata}/config/tautulli:/config:rw"
      ];
      ports = [
        "8181:8181/tcp"
      ];
      labels = {
        "com.centurylinklabs.watchtower.enable" = "true";
      };
      log-driver = "journald";
      extraOptions = [
        "--network-alias=tautulli"
        "--network=${dockerProject}_default"
      ];
    };
    zelec.dockerManager.plex = {
      containerNames = [
        "plex"
        "tautulli"
      ];
      networkNames = [
        "default"
      ];
    };
  };
}
