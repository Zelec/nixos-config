{
  flake.nixosModules.hostAmethyst = let
    btrfsDefaultMountOptions = ["noatime" "compress-force=zstd:1"];
    btrfsDefaultMountOptionsSSD = btrfsDefaultMountOptions ++ ["ssd" "discard"];
  in {
    disko.devices = {
      disk = {
        Amethyst = {
          type = "disk";
          device = "/dev/sda";
          content = {
            type = "gpt";
            partitions = {
              legacyBoot = {
                priority = 1;
                size = "3M";
                type = "EF02";
              };
              boot = {
                priority = 2;
                size = "3G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  # Forces FAT32
                  extraArgs = ["-F32"];
                  mountpoint = "/boot";
                  mountOptions = [
                    "fmask=0077"
                    "dmask=0077"
                  ];
                };
              };
              swap = {
                priority = 3;
                size = "4G";
                type = "8200";
                content = {
                  type = "swap";
                  resumeDevice = false;
                };
              };
              root = {
                priority = 4;
                size = "100%";
                type = "8300";
                content = {
                  type = "btrfs";
                  # Forces overwrite when formatting
                  extraArgs = ["-f"];
                  mountpoint = "/media/btrfsroots/root";
                  subvolumes = {
                    "@rootfs" = {
                      mountOptions = btrfsDefaultMountOptionsSSD;
                      mountpoint = "/";
                    };
                    "@nix" = {
                      mountOptions = btrfsDefaultMountOptionsSSD;
                      mountpoint = "/nix";
                    };
                    "@home" = {
                      mountOptions = btrfsDefaultMountOptionsSSD;
                      mountpoint = "/home";
                    };
                    "@cache" = {
                      mountOptions = btrfsDefaultMountOptionsSSD;
                      mountpoint = "/var/cache";
                    };
                    "@log" = {
                      mountOptions = btrfsDefaultMountOptionsSSD;
                      mountpoint = "/var/log";
                    };
                    "snapshots" = {};
                    "snapshots/local" = {};
                    "snapshots/remote" = {};
                    "snapshots/temp" = {};
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
