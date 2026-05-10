{
  flake.nixosModules.hostNSCommon = {
    lib,
    modulesPath,
    ...
  }: {
    imports = [
      (modulesPath + "/profiles/qemu-guest.nix")
    ];
    boot = {
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
        timeout = 5;
      };
      extraModulePackages = [];
      initrd = {
        systemd.enable = true;
        availableKernelModules = ["ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sr_mod" "virtio_blk"];
        kernelModules = [
          # "i915"
        ];
      };
      kernelParams = [
        # "udev.log_level=0"
      ];
    };

    networking.useDHCP = lib.mkDefault true;
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  };
}
