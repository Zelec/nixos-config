{
  flake.nixosModules.hostNSCommon = {
    disko.devices = {
      disk = {
        TG-DNS = {
          type = "disk";
          device = "/dev/vda";
          content = {
            type = "gpt";
            partitions = {
              boot = {
                priority = 1;
                name = "boot";
                size = "2G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  extraArgs = ["-F32"];
                  mountpoint = "/boot";
                  mountOptions = [
                    "fmask=0077"
                    "dmask=0077"
                  ];
                };
              };
              swap = {
                priority = 2;
                size = "4G";
                type = "8200";
                content = {
                  type = "swap";
                  resumeDevice = false;
                };
              };
              root = {
                priority = 3;
                size = "100%";
                type = "8300";
                content = {
                  type = "btrfs";
                  # mkfs.btrfs halts if it finds any recognized FS structure, -f forces it to continue regardless
                  extraArgs = ["-f"];
                  mountpoint = "/media/btrfsroots/root";
                  subvolumes = {
                    "@rootfs" = {
                      mountOptions = ["noatime"];
                      mountpoint = "/";
                    };
                    "@nix" = {
                      mountOptions = ["noatime" "compress=zstd"];
                      mountpoint = "/nix";
                    };
                    "@home" = {
                      mountOptions = ["noatime"];
                      mountpoint = "/home";
                    };
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
