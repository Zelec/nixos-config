# Really need to rework this module to properly be configurable
{
  self,
  lib,
  ...
}: let
  resticExcludes = [
    ".cache/"
    ".config/Code/Cache/"
    ".config/Code/CachedData/"
    ".config/VSCodium/Cache/"
    ".config/VSCodium/CachedData/"
    ".local/share/baloo/"
    ".local/share/Steam/"
    ".var/app/*/cache/"
    ".var/app/*/config/*/sessionData/Cache/"
    "nix/store/"
  ];
  sopsSetup = {
    sopsFile = ./secrets.yml;
  };
  mountPoint = "/media/secureArchiveStorage";
  mapperName = "rotatedDrives";
  mapperFullName = "/dev/mapper/${mapperName}";
in {
  perSystem = {pkgs, ...}: let
    backupConfig = {
      "/media/Backups/btrbk/Temp" = {
        "Lapis" = {
          "/media/Backups/btrbk/Lapis" = [
            "rootfs"
            "log"
          ];
        };
        "Pearl" = {
          "/media/Backups/btrbk/Pearl" = [
            "@"
            "@home"
            "@log"
            "@libvirt-images"
          ];
        };
      };
      "/media/btrfsroots/Storage_01/snapshots/archive" = {
        "TimeDial" = {
          "/media/btrfsroots/Storage_01/snapshots/local" = [
            "@home"
            "@log"
            "@rootfs"
            "@NVMe_01"
            "@SSD_01"
            "@SSD-VMs"
            "@Storage_01"
            "@Storage-VMs"
          ];
        };
      };
    };
    backupEnvFile = ''
      export BACKUP_CONFIG="${pkgs.writeText "backup-snapshot-prep-config.json" (builtins.toJSON backupConfig)}"
    '';
  in {
    packages = {
      btrbk-mass-backup-snapshot-prep = pkgs.writers.writePython3Bin "btrbk-mass-backup-snapshot-prep" {
        flakeIgnore = [
          "E111"
          "E114"
          "E121"
          "E501"
        ];
        makeWrapperArgs = [
          "--prefix"
          "PATH"
          ":"
          "${lib.makeBinPath [pkgs.btrfs-progs]}"
        ];
      } (builtins.readFile ./script.py);
      btrbk-mass-backup = pkgs.writers.writeBashBin "btrbk-mass-backup" ''
        set -euo pipefail
        export $(grep -v '^#' ${pkgs.writeText "backup_env_file.env" backupEnvFile} | xargs)

        if [ "$EUID" -ne 0 ]; then
          echo "Please run as root"
          exit
        fi

        CONFIG="$BACKUP_CONFIG"

        prepare_snapshots() {
          # Check if the cryptdevice is opened
          if [ ! -e "${mapperFullName}" ]; then
            echo "Error: ${mapperFullName} not found. Is the drive plugged in?"
            exit 1
          fi
          # Double check that it's actually mounted where we expect
          if ! ${pkgs.util-linux}/bin/mountpoint -q "${mountPoint}"; then
            echo "Error: Mount point ${mountPoint} not active. Automount failed?"
            exit 1
          fi
          echo "Prepping snapshots"
          ${lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.btrbk-mass-backup-snapshot-prep} --config "''${CONFIG}" --action prepare
        }

        cleanup_snapshots() {
          echo "Cleaning snapshots"
          ${lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.btrbk-mass-backup-snapshot-prep} --config "''${CONFIG}" --action cleanup
          # Double check if the filesystem is still mounted and tell it to unmount if needed
          if ${pkgs.util-linux}/bin/mountpoint -q "${mountPoint}"; then
            echo "Syncing drive..."
            ${pkgs.coreutils}/bin/sync "${mountPoint}"
            echo "Unmounting drive..."
            ${pkgs.util-linux}/bin/umount "${mountPoint}"
            echo "...Done!"
          fi
        }

        case "$*" in
          --prepare)
            prepare_snapshots
            ;;
          --cleanup)
            cleanup_snapshots
            ;;
          *)
            echo "Usage: $0 {--prepare|--cleanup}"
            ;;
        esac
      '';
    };
    devShells.btrbk-mass-backup = pkgs.mkShell {
      packages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.btrbk-mass-backup-snapshot-prep
        self.packages.${pkgs.stdenv.hostPlatform.system}.btrbk-mass-backup
      ];
      shellHook = ''
        echo "Entering Devshell"
        export ORIGPS1="$PS1"
        export PS1="DEVSHELL-$ORIGPS1"
      '';
    };
  };
  flake.nixosModules.btrbk-mass-backup = {
    config,
    pkgs,
    ...
  }: {
    sops.secrets.archive_backups_repo_key = sopsSetup;
    sops.secrets.luks_encryption_key = sopsSetup;
    services.restic.backups.archive = {
      backupPrepareCommand = "${lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.btrbk-mass-backup} --prepare";
      backupCleanupCommand = "${lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.btrbk-mass-backup} --cleanup";
      passwordFile = config.sops.secrets.archive_backups_repo_key.path;
      pruneOpts = [
        "--keep-daily 14"
        "--keep-weekly 8"
        "--keep-monthly 12"
        "--keep-yearly 75"
      ];
      progressFps = 0.2;
      exclude = resticExcludes;
      paths = [
        "/media/Backups/btrbk/Temp"
        "/media/btrfsroots/Storage_01/snapshots/archive"
      ];
      repository = "${mountPoint}/restic-archive";
      initialize = true;
      timerConfig = {
        OnCalendar = "*-*-* 00:13:00";
      };
    };
    # Requires mount to be alive, should allow systemd to handle automount before it runs this
    systemd.services.restic-backups-archive = {
      unitConfig = {
        RequiresMountsFor = "${mountPoint}";
      };
    };
    # Manually defined because Nix doesn't allow multiple entries with the same volume name
    environment.etc.crypttab = {
      mode = "0600";
      text = ''
        # <volume-name> <encrypted-device> [key-file] [options]
        # WD 5TB Drive UUID 1e44c823-a56a-4bc9-84d2-01ecb5f37bb3
        # Seagate 4TB  UUID 55230080-e5ca-43fa-8475-2ae1fc93cc65
        # Unified Label for all drives
        ${mapperName} /dev/disk/by-label/TG-Backup-Drive-Crypt ${config.sops.secrets.luks_encryption_key.path} luks,noauto,nofail,discard
      '';
    };
    # # Broken, very silly, manually had to make crypttab
    # boot.initrd.luks.devices = {
    #   "${mapperName}" = {
    #     device = "/dev/disk/by-label/TG-Backup-Drive-Crypt";
    #     keyFile = config.sops.secrets.luks_encryption_key.path;
    #     crypttabExtraOpts = ["luks" "noauto" "nofail"];
    #   };
    # };
    # Closes encrypted FS when not in use
    # Need to change override strategy from asDropinIfExists to asDropin because otherwise NixOS will not let systemd generate the
    # service on boot
    systemd.services."systemd-cryptsetup@${mapperName}" = {
      overrideStrategy = "asDropin";
      unitConfig = {
        StopWhenUnneeded = true;
        StopPropagatedFrom = ["${lib.replaceStrings ["/"] ["-"] (lib.removePrefix "/" mountPoint)}.mount"];
      };
    };
    # Automounts to mountpoint when needed, auto closes after 20 mins of inactivity
    systemd.mounts = [
      {
        where = "${mountPoint}";
        what = "${mapperFullName}";
        type = "ext4";
        mountConfig = {
          TimeoutSec = "15s";
          Options = "noatime,noauto,nofail";
        };
        unitConfig = {
          BindsTo = ["systemd-cryptsetup@${mapperName}.service"];
          After = ["systemd-cryptsetup@${mapperName}.service"];
          Requires = ["systemd-cryptsetup@${mapperName}.service"];
        };
      }
    ];
    systemd.automounts = [
      {
        description = "Automount for Rotated Encrypted Data Drives";
        where = "${mountPoint}";
        wantedBy = ["multi-user.target"];
        automountConfig = {
          TimeoutIdleSec = "300s";
        };
      }
    ];
    # Creates mount folder and makes it immutable
    systemd.tmpfiles.rules = [
      "d ${mountPoint} 0750 root root - -"
      "H ${mountPoint} - - - - +i"
    ];
  };
}
