{
  flake.nixosModules.hostRepairUSB = {
    config,
    lib,
    pkgs,
    modulesPath,
    ...
  }: {
    imports = [
      "${modulesPath}/installer/scan/not-detected.nix"
      "${modulesPath}/profiles/all-hardware.nix"
    ];

    # Include support for various filesystems and tools to create / manipulate them.
    boot.supportedFilesystems =
      ["btrfs" "reiserfs" "cifs" "f2fs" "jfs" "ntfs" "reiserfs" "vfat" "xfs"]
      ++ lib.optional (lib.meta.availableOn pkgs.stdenv.hostPlatform config.boot.zfs.package) "zfs";
    # boot.loader.grub.device = lib.mkDefault "/dev/disk/by-id/usb-Samsung_Flash_Drive_0347018080000001-0:0";
    boot.initrd = {
      # Allows FDE by LVM over LUKS
      luks.devices = {
        RepairUSB-crypt = {
          # device = lib.mkDefault "/dev/disk/by-id/usb-Samsung_Flash_Drive_0347018080000001-0:0-part4";
          allowDiscards = true;
        };
      };
    };
    # Configure host id for ZFS to work
    networking.hostId = lib.mkDefault "8425e349";
    networking.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
