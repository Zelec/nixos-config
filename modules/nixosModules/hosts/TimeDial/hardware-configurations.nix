{inputs, ...}: {
  flake.nixosModules.hostTimeDial = {
    config,
    lib,
    pkgs,
    modulesPath,
    ...
  }: let
    btrfsDefaultMountOptions = ["noatime"];
    btrfsDefaultMountOptionsSSD = btrfsDefaultMountOptions ++ ["ssd"];
    btrfsDefaultMountOptionsHDD = btrfsDefaultMountOptions ++ ["autodefrag"];
  in {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
      inputs.nixos-hardware.nixosModules.common-cpu-amd
      inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
      inputs.nixos-hardware.nixosModules.common-cpu-amd-zenpower
      inputs.nixos-hardware.nixosModules.common-pc-ssd
    ];

    boot = {
      initrd = {
        availableKernelModules = ["nvme" "xhci_pci" "ahci" "mpt3sas" "uas" "usbhid" "sd_mod"];
        kernelModules = ["nvidia" "nvidia_modeset" "nvidia_drm"];
      };
      kernelPackages = pkgs.linuxPackages_zen;
      kernelParams = [
        "tsc=reliable"
        "clocksource=tsc"
      ];
      kernelModules = ["kvm-amd"];
      extraModulePackages = [];
    };

    fileSystems = {
      # Main SSD array
      # systemd-boot will freakout if umask/fmask aren't set to disallow normal users from reading the seed files
      "/boot" = {
        device = "/dev/disk/by-uuid/165B-2F3C";
        fsType = "vfat";
        options = ["fmask=0077" "dmask=0077"];
      };
      "/" = {
        device = "/dev/disk/by-uuid/f0eea91b-10db-4a7a-9ad6-deb3ce469497";
        fsType = "btrfs";
        options = btrfsDefaultMountOptionsSSD ++ ["subvol=@rootfs"];
      };
      "/home" = {
        device = "/dev/disk/by-uuid/f0eea91b-10db-4a7a-9ad6-deb3ce469497";
        fsType = "btrfs";
        options = btrfsDefaultMountOptionsSSD ++ ["subvol=@home"];
      };
      "/nix" = {
        device = "/dev/disk/by-uuid/f0eea91b-10db-4a7a-9ad6-deb3ce469497";
        fsType = "btrfs";
        options = btrfsDefaultMountOptionsSSD ++ ["compress-force=zstd:1" "subvol=@nix"];
      };
      "/var/cache" = {
        device = "/dev/disk/by-uuid/f0eea91b-10db-4a7a-9ad6-deb3ce469497";
        fsType = "btrfs";
        options = btrfsDefaultMountOptionsSSD ++ ["subvol=@cache"];
      };
      "/var/log" = {
        device = "/dev/disk/by-uuid/f0eea91b-10db-4a7a-9ad6-deb3ce469497";
        fsType = "btrfs";
        options = btrfsDefaultMountOptionsSSD ++ ["subvol=@log"];
      };
      "/var/local/libvirt-images/ssd-backed" = {
        device = "/dev/disk/by-uuid/f0eea91b-10db-4a7a-9ad6-deb3ce469497";
        fsType = "btrfs";
        options = btrfsDefaultMountOptionsSSD ++ ["subvol=@SSD-VMs"];
      };
      "/media/btrfsroots/root" = {
        device = "/dev/disk/by-uuid/f0eea91b-10db-4a7a-9ad6-deb3ce469497";
        fsType = "btrfs";
        options = btrfsDefaultMountOptionsSSD ++ ["subvol=/"];
      };

      # Spare NVMe Drive for gaming
      "/media/NVMe_01" = {
        device = "/dev/disk/by-uuid/e1051962-3757-453f-ac88-1485cd1442b1";
        fsType = "btrfs";
        options = btrfsDefaultMountOptionsSSD ++ ["subvol=@NVMe_01"];
      };
      "/opt/dockerservices/docker-stream-headless/extSSD" = {
        device = "/dev/disk/by-uuid/e1051962-3757-453f-ac88-1485cd1442b1";
        fsType = "btrfs";
        options = btrfsDefaultMountOptionsSSD ++ ["subvol=@NVMe_SteamHeadless"];
      };
      "/media/btrfsroots/NVMe_01" = {
        device = "/dev/disk/by-uuid/e1051962-3757-453f-ac88-1485cd1442b1";
        fsType = "btrfs";
        options = btrfsDefaultMountOptionsSSD ++ ["subvol=/"];
      };

      # Spare SATA SSD used as a scratch disk
      "/media/SSD_01" = {
        device = "/dev/disk/by-uuid/d2c30975-c6df-4fc3-b918-132f5c340f31";
        fsType = "btrfs";
        options = btrfsDefaultMountOptionsSSD ++ ["subvol=@SSD_01"];
      };
      "/media/btrfsroots/SSD_01" = {
        device = "/dev/disk/by-uuid/d2c30975-c6df-4fc3-b918-132f5c340f31";
        fsType = "btrfs";
        options = btrfsDefaultMountOptionsSSD ++ ["subvol=/"];
      };

      # HDD Array for bulk storage
      "/media/Backups" = {
        device = "/dev/disk/by-uuid/27383973-3402-458b-9c4b-925d106cd832";
        fsType = "btrfs";
        options = btrfsDefaultMountOptionsHDD ++ ["subvol=@Backups"];
      };
      "/media/Storage_01" = {
        device = "/dev/disk/by-uuid/27383973-3402-458b-9c4b-925d106cd832";
        fsType = "btrfs";
        options = btrfsDefaultMountOptionsHDD ++ ["subvol=@Storage_01"];
      };
      "/var/local/libvirt-images/storage-backed" = {
        device = "/dev/disk/by-uuid/27383973-3402-458b-9c4b-925d106cd832";
        fsType = "btrfs";
        options = btrfsDefaultMountOptionsHDD ++ ["subvol=@Storage-VMs"];
      };
      "/media/btrfsroots/Storage_01" = {
        device = "/dev/disk/by-uuid/27383973-3402-458b-9c4b-925d106cd832";
        fsType = "btrfs";
        options = btrfsDefaultMountOptionsHDD ++ ["subvol=/"];
      };
    };
    swapDevices = [
      {
        device = "/dev/disk/by-uuid/4149c715-cfcc-4e1c-908e-c0ccf7c6cbc2";
      }
      {
        device = "/dev/disk/by-uuid/3518200d-4fc5-48e2-b35e-1667d4b699f4";
      }
    ];

    networking.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
