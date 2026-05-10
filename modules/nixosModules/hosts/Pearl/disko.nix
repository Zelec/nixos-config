# Not in use yet
# {
#   flake.nixosModules.hostPearl = let
#     btrfsDefaultMountOptions = ["noatime"];
#     btrfsDefaultMountOptionsSSD = btrfsDefaultMountOptions ++ ["ssd" "discard"];
#   in {
#     disko.devices = {
#       disk = {
#         Pearl = {
#           type = "disk";
#           device = "/dev/disk/by-id/nvme-CT2000P3PSSD8_2410E89E0C63";
#           content = {
#             type = "gpt";
#             partitions = {
#               boot = {
#                 priority = 1;
#                 name = "boot";
#                 size = "5G";
#                 type = "EF00";
#                 content = {
#                   type = "filesystem";
#                   format = "vfat";
#                   # Forces FAT32
#                   extraArgs = ["-F32"];
#                   mountpoint = "/boot";
#                   mountOptions = [
#                     "fmask=0077"
#                     "dmask=0077"
#                   ];
#                 };
#               };
#               swap = {
#                 priority = 2;
#                 name = "swap";
#                 size = "8G";
#                 type = "8200";
#                 content = {
#                   type = "swap";
#                   resumeDevice = false;
#                 };
#               };
#               root = {
#                 priority = 3;
#                 size = "100%";
#                 type = "8300";
#                 content = {
#                   type = "btrfs";
#                   # Forces overwrite when formatting
#                   extraArgs = ["-f"];
#                   name = "root";
#                   mountpoint = "/media/btrfsroots/root";
#                   subvolumes = {
#                     "@rootfs" = {
#                       mountOptions = btrfsDefaultMountOptionsSSD;
#                       mountpoint = "/";
#                     };
#                     "@nix" = {
#                       mountOptions = btrfsDefaultMountOptionsSSD ++ ["compress-force=zstd:1"];
#                       mountpoint = "/nix";
#                     };
#                     "@home" = {
#                       mountOptions = btrfsDefaultMountOptionsSSD;
#                       mountpoint = "/home";
#                     };
#                     "@cache" = {
#                       mountOptions = btrfsDefaultMountOptionsSSD;
#                       mountpoint = "/var/cache";
#                     };
#                     "@log" = {
#                       mountOptions = btrfsDefaultMountOptionsSSD;
#                       mountpoint = "/var/log";
#                     };
#                     "@libvirt-images" = {
#                       mountOptions = btrfsDefaultMountOptionsSSD ++ ["compress-force=zstd:1"];
#                       mountpoint = "/var/lib/libvirt/images";
#                     };
#                   };
#                 };
#               };
#             };
#           };
#         };
#       };
#     };
#   };
# }
{}
