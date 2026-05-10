let
  btrfsDefaultMountOptions = ["noatime"];
in {
  flake.nixosModules.hostRepairUSB = {
    disko.devices = {
      disk = {
        RepairUSB = {
          type = "disk";
          device = "/dev/disk/by-id/usb-Samsung_Flash_Drive_0370423090003154-0:0";
          content = {
            type = "gpt";
            partitions = {
              legacyBoot = {
                priority = 1;
                size = "1M";
                type = "EF02";
              };
              boot = {
                priority = 2;
                name = "boot";
                size = "5G";
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
              crypt = {
                priority = 3;
                size = "100%";
                type = "8E00";
                content = {
                  type = "luks";
                  name = "RepairUSB-crypt";
                  extraOpenArgs = [];
                  settings = {
                    allowDiscards = true;
                  };
                  content = {
                    type = "lvm_pv";
                    vg = "RepairUSB-vg";
                  };
                };
              };
            };
          };
        };
      };
      lvm_vg = {
        "RepairUSB-vg" = {
          type = "lvm_vg";
          lvs = {
            swap = {
              size = "2G";
              content = {
                type = "swap";
                resumeDevice = false;
              };
            };
            root = {
              size = "100%FREE";
              content = {
                type = "btrfs";
                # mkfs.btrfs halts if it finds any recognized FS structure, -f forces it to continue regardless
                extraArgs = ["-f"];
                mountpoint = "/media/btrfsroots/root";
                subvolumes = {
                  "@rootfs" = {
                    mountOptions = btrfsDefaultMountOptions;
                    mountpoint = "/";
                  };
                  "@nix" = {
                    mountOptions = btrfsDefaultMountOptions ++ ["compress-force=zstd:1"];
                    mountpoint = "/nix";
                  };
                  "@home" = {
                    mountOptions = btrfsDefaultMountOptions;
                    mountpoint = "/home";
                  };
                  "@cache" = {
                    mountOptions = btrfsDefaultMountOptions;
                    mountpoint = "/var/cache";
                  };
                  "@log" = {
                    mountOptions = btrfsDefaultMountOptions;
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
