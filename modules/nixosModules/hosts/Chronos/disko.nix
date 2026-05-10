let
  btrfsDefaultMountOptions = ["noatime"];
  btrfsDefaultMountOptionsSSD = btrfsDefaultMountOptions ++ ["ssd" "discard"];
in {
  flake.nixosModules.hostChronos = {
    disko.devices = {
      disk = {
        Chronos-root = {
          type = "disk";
          device = "/dev/disk/by-id/nvme-CT2000P3PSSD8_2441E98E710E";
          content = {
            type = "gpt";
            partitions = {
              boot = {
                priority = 1;
                name = "boot";
                size = "5G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  # Forces FAT32
                  extraArgs = ["-F32"];
                  mountpoint = "/boot";
                  # systemd-boot will produce a warning if umask/fmask aren't set to
                  # disallow normal users from reading the seed files
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
                  name = "Chronos-crypt";
                  extraOpenArgs = [];
                  settings = {
                    allowDiscards = true;
                  };
                  content = {
                    type = "lvm_pv";
                    vg = "Chronos-vg";
                  };
                };
              };
            };
          };
        };
      };
      lvm_vg = {
        Chronos-vg = {
          type = "lvm_vg";
          lvs = {
            swap = {
              size = "32G";
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
                    mountOptions = btrfsDefaultMountOptionsSSD;
                    mountpoint = "/";
                  };
                  "@nix" = {
                    mountOptions = btrfsDefaultMountOptionsSSD ++ ["compress-force=zstd:1"];
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
                  "@libvirt-images" = {
                    mountOptions = btrfsDefaultMountOptionsSSD ++ ["compress-force=zstd:1"];
                    mountpoint = "/var/lib/libvirt/images";
                  };
                  "snapshots" = {};
                  "snapshots/local" = {};
                  "snapshots/temp" = {};
                };
              };
            };
          };
        };
      };
    };
  };
}
