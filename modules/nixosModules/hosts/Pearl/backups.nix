{
  flake.nixosModules.hostPearl = {
    config,
    pkgs,
    lib,
    ...
  }: let
    sopsHostSecretSetup = {
      sopsFile = ./secrets.yml;
    };
    btrbkSopsSetup = lib.mergeAttrsList [
      sopsHostSecretSetup
      {
        owner = config.systemd.services.btrbk-remote_backup.serviceConfig.User;
        group = config.systemd.services.btrbk-remote_backup.serviceConfig.Group;
      }
    ];
    btrfsSnapshotRootVol = "/media/btrfsroots/root";
    protectedSubVols = [
      "@"
      "@home"
      "@log"
      "@libvirt-images"
    ];
    btrbkVols = lib.genAttrs protectedSubVols (name: {});
  in {
    environment.systemPackages = with pkgs; [
      borgbackup
      borgmatic
      restic
    ];
    sops.secrets."backups/repo_key" = sopsHostSecretSetup;
    sops.secrets."backups/restic_repo" = sopsHostSecretSetup;
    sops.secrets."backups/btrbk_ssh_key_private" = btrbkSopsSetup;
    services = {
      btrbk = {
        instances."local_snapshots" = {
          onCalendar = "*-*-* *:00,15,30,45:00";
          settings = {
            timestamp_format = "long";
            transaction_log = "/var/log/btrbk_local_snapshots.log";
            snapshot_dir = "snapshots/local";
            snapshot_preserve_min = "1h";
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
          onCalendar = "*-*-* *:00:00";
          settings = {
            timestamp_format = "long";
            transaction_log = "/var/log/btrbk_remote_backup.log";
            snapshot_dir = "snapshots/remote";
            snapshot_preserve_min = "latest";
            snapshot_preserve = "2h 4d";
            target_preserve_min = "latest";
            target_preserve = "6h 7d";
            ssh_identity = config.sops.secrets."backups/btrbk_ssh_key_private".path;
            ssh_user = "root";
            stream_compress = "zstd";
            volume."${btrfsSnapshotRootVol}" = {
              target = "ssh://timedial.timeguard.ca/media/Backups/btrbk/Pearl";
              subvolume = btrbkVols;
            };
          };
        };
      };
    };
  };
}
