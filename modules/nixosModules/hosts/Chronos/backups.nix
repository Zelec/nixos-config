{
  flake.nixosModules.hostChronos = {
    config,
    pkgs,
    ...
  }: let
    sopsHostSecretSetup = {
      sopsFile = ./secrets.yml;
    };
    btrfsSnapshotRootVol = "/media/btrfsroots/root";
    btrfsSnapshotSubVols = [
      "@rootfs"
      "@home"
      "@log"
    ];
    # borgmaticExcludes = [
    #   "/home/*/.cache"
    #   "/home/*/.config/Code/Cache"
    #   "/home/*/.config/Code/CachedData"
    #   "/home/*/.config/VSCodium/Cache"
    #   "/home/*/.config/VSCodium/CachedData"
    #   "/home/*/.local/share/baloo"
    #   "/home/*/.local/share/Steam"
    #   "/home/*/.var/app/*/cache"
    #   "/home/*/.var/app/*/config/*/sessionData/Cache"
    # ];
    resticExcludes = [
      "@home/*/.cache"
      "@home/*/.config/Code/Cache"
      "@home/*/.config/Code/CachedData"
      "@home/*/.config/VSCodium/Cache"
      "@home/*/.config/VSCodium/CachedData"
      "@home/*/.local/share/baloo"
      "@home/*/.local/share/Steam"
      "@home/*/.var/app/*/cache"
      "@home/*/.var/app/*/config/*/sessionData/Cache"
    ];
    resticPaths = [
      "${btrfsSnapshotRootVol}/snapshots/temp"
    ];
    resticBackupScript = pkgs.writeShellApplication {
      name = "restic-btrfs-snapshot-prepare-root";
      runtimeInputs = with pkgs; [
        btrfs-progs
        jq
      ];
      text = ''
        ROOTVOL="${btrfsSnapshotRootVol}"
        JSONSUBVOLS='${builtins.toJSON btrfsSnapshotSubVols}'
        readarray -t SUBVOLS <<<"$(echo "''${JSONSUBVOLS}" | jq -r '.[]')"


        usage() {
          echo "Usage: $0 -p|-c"
          echo "-p: Prepare snapshots"
          echo "-c: Cleanup snapshots"
        }

        prepare() {
          for i in "''${SUBVOLS[@]}"; do
            FULLPATH="''${ROOTVOL}/''${i}"
            SNAPSHOTPATH="''${ROOTVOL}/snapshots/temp/''${i}"
            if [ -d "''${SNAPSHOTPATH}" ]; then
              btrfs subvolume delete "''${SNAPSHOTPATH}"
            fi
            btrfs subvolume snapshot -r "''${FULLPATH}" "''${SNAPSHOTPATH}"
          done
        }

        cleanup() {
          for i in "''${SUBVOLS[@]}"; do
            SNAPSHOTPATH="''${ROOTVOL}/snapshots/temp/''${i}"
            btrfs subvolume delete "''${SNAPSHOTPATH}"
          done
        }

        if [ "''$#" -ne 1 ]; then
          usage
          exit 1
        fi

        if [ "''$*" == "-p" ]; then
          prepare
          exit 0
        elif [ "''$*" == "-c" ]; then
          cleanup
          exit 0
        else
          usage
          exit 1
        fi
      '';
    };
  in {
    environment.systemPackages = with pkgs; [
      borgbackup
      borgmatic
      restic
      restic-browser
    ];
    sops.secrets.backups_repo_key = sopsHostSecretSetup;
    sops.secrets.backups_restic_repo = sopsHostSecretSetup;
    sops.secrets.backups_ssh_key_private = sopsHostSecretSetup;
    services = {
      btrbk = {
        instances."local_snapshots" = {
          onCalendar = "*-*-* *:00:00";
          settings = {
            timestamp_format = "long";
            snapshot_dir = "snapshots/local";
            snapshot_preserve_min = "latest";
            snapshot_preserve = "4h";
            # target_preserve_min = "latest";
            # target_preserve = "6h 14d";
            volume."/media/btrfsroots/root" = {
              subvolume = {
                "@home" = {};
                "@rootfs" = {};
                "@libvirt-images" = {};
                "@log" = {};
              };
            };
          };
        };
      };
      restic.backups = {
        remote_backup = {
          backupPrepareCommand = "${resticBackupScript}/bin/restic-btrfs-snapshot-prepare-root -p";
          backupCleanupCommand = "${resticBackupScript}/bin/restic-btrfs-snapshot-prepare-root -c";
          passwordFile = config.sops.secrets.backups_repo_key.path;
          # extraOptions = [
          #   "sftp.command='ssh -p23 -i ${config.sops.secrets.backups_ssh_key_private.path} -s sftp'"
          # ];
          pruneOpts = [
            "--keep-daily 7"
            "--keep-weekly 5"
            "--keep-monthly 12"
            "--keep-yearly 75"
          ];
          progressFps = 0.2;
          exclude = resticExcludes;
          paths = resticPaths;
          repositoryFile = config.sops.secrets.backups_restic_repo.path;
          timerConfig = {
            OnCalendar = "*-*-* 02:00:00";
          };
        };
      };
    };
  };
}
