{
  flake.nixosModules.hostTimeDial = {...}: {
    services.btrbk = {
      instances."local_snapshots" = {
        onCalendar = "*-*-* *:00:00";
        settings = {
          timestamp_format = "long";
          snapshot_dir = "snapshots/local";
          snapshot_preserve_min = "latest";
          snapshot_preserve = "6h";
          target_preserve_min = "latest";
          target_preserve = "12h 7d";
          volume."/media/btrfsroots/root" = {
            target = "/media/btrfsroots/Storage_01/snapshots/local";
            subvolume = {
              "@rootfs" = {};
              "@home" = {};
              "@log" = {};
              "@SSD-VMs" = {};
            };
          };
          volume."/media/btrfsroots/Storage_01" = {
            snapshot_preserve_min = "latest";
            snapshot_preserve = "12h 7d";
            subvolume = {
              "@Storage_01" = {};
              "@Storage-VMs" = {};
            };
          };
          volume."/media/btrfsroots/SSD_01" = {
            target = "/media/btrfsroots/Storage_01/snapshots/local";
            subvolume = {
              "@SSD_01" = {};
            };
          };
          volume."/media/btrfsroots/NVMe_01" = {
            target = "/media/btrfsroots/Storage_01/snapshots/local";
            subvolume = {
              "@NVMe_01" = {};
            };
          };
        };
      };
    };
  };
}
