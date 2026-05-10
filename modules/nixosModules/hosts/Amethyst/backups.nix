{
  flake.nixosModules.hostAmethyst = {
    config,
    pkgs,
    lib,
    ...
  }: let
    sopsHostSecretSetup = {
      sopsFile = ./secrets.yml;
    };
    btrfsSnapshotRootVol = "/media/btrfsroots/root";
    protectedSubVols = [
      "@rootfs"
      "@home"
      "@log"
    ];
    btrbkVols = lib.genAttrs protectedSubVols (name: {});
  in {
    environment.systemPackages = with pkgs; [
      borgbackup
      borgmatic
      restic
    ];
    sops.secrets.btrbk_ssh_key_private = lib.mergeAttrsList [
      sopsHostSecretSetup
      {
        owner = config.systemd.services.btrbk-remote_backup.serviceConfig.User;
        group = config.systemd.services.btrbk-remote_backup.serviceConfig.Group;
      }
    ];
    services = {
      btrbk = {
        instances."local_snapshots" = {
          onCalendar = "*-*-* *:00:00";
          settings = {
            timestamp_format = "long";
            transaction_log = "/var/log/btrbk_local_snapshots.log";
            snapshot_dir = "snapshots/local";
            snapshot_preserve_min = "latest";
            snapshot_preserve = "6h 14d";
            # target_preserve_min = "latest";
            # target_preserve = "6h 14d";
            volume."${btrfsSnapshotRootVol}" = {
              # target = "/media/btrfsroots/Armory/snapshots";
              subvolume = btrbkVols;
            };
          };
        };
        instances."remote_backup" = {
          onCalendar = "*-*-* 1:30:00";
          settings = {
            timestamp_format = "long";
            transaction_log = "/var/log/btrbk_remote_backup.log";
            snapshot_dir = "snapshots/remote";
            snapshot_preserve_min = "latest";
            snapshot_preserve = "4d";
            target_preserve_min = "latest";
            target_preserve = "7d";
            ssh_identity = config.sops.secrets.btrbk_ssh_key_private.path;
            ssh_user = "root";
            stream_compress = "zstd";
            volume."${btrfsSnapshotRootVol}" = {
              target = "ssh://timedial.timeguard.ca/media/Backups/btrbk/Amethyst";
              subvolume = btrbkVols;
            };
          };
        };
      };
    };
  };
}
