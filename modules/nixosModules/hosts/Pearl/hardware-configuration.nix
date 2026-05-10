{inputs, ...}: {
  flake.nixosModules.hostPearl = {
    config,
    lib,
    modulesPath,
    ...
  }: let
    btrfsDefaultMountOptions = ["noatime"];
    btrfsDefaultMountOptionsSSD = btrfsDefaultMountOptions ++ ["ssd" "discard"];
  in {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
      "${inputs.nixos-hardware}/common/cpu/intel/kaby-lake"
      "${inputs.nixos-hardware}/common/gpu/intel/kaby-lake"
    ];

    boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"];
    boot.initrd.kernelModules = [];
    boot.kernelModules = ["kvm-intel"];
    boot.extraModulePackages = [];
    security.tpm2 = {
      enable = true;
      pkcs11.enable = true;
      tctiEnvironment.enable = true;
    };

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-uuid/5c45e6ab-9696-41ad-b078-65c374c835c5";
        fsType = "btrfs";
        options = btrfsDefaultMountOptionsSSD ++ ["subvol=@"];
      };
      "/nix" = {
        device = "/dev/disk/by-uuid/5c45e6ab-9696-41ad-b078-65c374c835c5";
        fsType = "btrfs";
        options = btrfsDefaultMountOptionsSSD ++ ["compress-force=zstd:1" "subvol=@nix"];
      };
      "/home" = {
        device = "/dev/disk/by-uuid/5c45e6ab-9696-41ad-b078-65c374c835c5";
        fsType = "btrfs";
        options = btrfsDefaultMountOptionsSSD ++ ["subvol=@home"];
      };
      "/var/cache" = {
        device = "/dev/disk/by-uuid/5c45e6ab-9696-41ad-b078-65c374c835c5";
        fsType = "btrfs";
        options = btrfsDefaultMountOptionsSSD ++ ["subvol=@cache"];
      };
      "/var/log" = {
        device = "/dev/disk/by-uuid/5c45e6ab-9696-41ad-b078-65c374c835c5";
        fsType = "btrfs";
        options = btrfsDefaultMountOptionsSSD ++ ["subvol=@log"];
      };
      "/var/lib/libvirt/images" = {
        device = "/dev/disk/by-uuid/5c45e6ab-9696-41ad-b078-65c374c835c5";
        fsType = "btrfs";
        options = btrfsDefaultMountOptionsSSD ++ ["compress-force=zstd:1" "subvol=@libvirt-images"];
      };
      "/media/btrfsroots/root" = {
        device = "/dev/disk/by-uuid/5c45e6ab-9696-41ad-b078-65c374c835c5";
        fsType = "btrfs";
        options = btrfsDefaultMountOptionsSSD ++ ["subvol=/"];
      };
      "/boot" = {
        # systemd-boot will freakout if umask/fmask aren't set to disallow normal users from reading the seed files
        device = "/dev/disk/by-uuid/AE90-8E5D";
        fsType = "vfat";
        options = ["fmask=0077" "dmask=0077"];
      };
      # "/media/btrfsroots/Armory" = {
      #   device = "/dev/disk/by-label/Armory";
      #   fsType = "btrfs";
      #   options = [ "noatime" "compress-force=zstd:1" "ssd" "space_cache=v2" "commit=15" "subvol=/" ];
      # };
    };

    swapDevices = [
      {device = "/dev/disk/by-uuid/506c3212-d94a-494f-9d57-244b3ca6c3e1";}
    ];

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.enp2s0.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
