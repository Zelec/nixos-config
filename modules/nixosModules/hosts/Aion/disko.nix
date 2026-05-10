{
  flake.nixosModules.hostAion = {
    disko.devices = {
      disk = {
        Aion-root = {
          type = "disk";
          device = "/dev/disk/by-id/nvme-WDC_PC_SN730_SDBPNTY-256G-1006_21080Y806035";
          content = {
            type = "gpt";
            partitions = {
              boot = {
                priority = 1;
                size = "5G";
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
              crypt = {
                priority = 2;
                size = "100%";
                type = "8E00";
                content = {
                  type = "luks";
                  name = "Aion-crypt";
                  extraOpenArgs = [];
                  settings = {
                    allowDiscards = true;
                  };
                  content = {
                    type = "lvm_pv";
                    vg = "Aion-vg";
                  };
                };
              };
            };
          };
        };
      };
      lvm_vg = {
        Aion-vg = {
          type = "lvm_vg";
          lvs = {
            swap = {
              size = "16G";
              content = {
                type = "swap";
                resumeDevice = true;
              };
            };
            root = {
              size = "100%FREE";
              content = {
                type = "btrfs";
                # Forces overwrite when formatting
                extraArgs = ["-f"];
                mountpoint = "/media/btrfsroots/root";
                subvolumes = {
                  "@rootfs" = {
                    mountOptions = ["noatime" "compress-force=zstd:1" "ssd" "space_cache=v2" "commit=15"];
                    mountpoint = "/";
                  };
                  "@nix" = {
                    mountOptions = ["noatime" "compress-force=zstd:1" "ssd" "space_cache=v2" "commit=15"];
                    mountpoint = "/nix";
                  };
                  "@home" = {
                    mountOptions = ["noatime" "compress-force=zstd:1" "ssd" "space_cache=v2" "commit=15"];
                    mountpoint = "/home";
                  };
                  "@cache" = {
                    mountOptions = ["noatime" "compress-force=zstd:1" "ssd" "space_cache=v2" "commit=15"];
                    mountpoint = "/var/cache";
                  };
                  "@log" = {
                    mountOptions = ["noatime" "compress-force=zstd:1" "ssd" "space_cache=v2" "commit=15"];
                    mountpoint = "/var/log";
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
