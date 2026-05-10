{inputs, ...}: {
  flake.nixosModules.hostAmethyst = {
    config,
    lib,
    modulesPath,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
      (modulesPath + "/profiles/qemu-guest.nix")
    ];
    boot = {
      initrd = {
        availableKernelModules = ["ata_piix" "virtio_pci" "virtio_scsi" "sd_mod"];
        kernelModules = [];
      };
      kernelModules = ["kvm-intel"];
      extraModulePackages = [];
      # Bootloader.
      # Uses grub to allow bios & efi booting
      loader = {
        systemd-boot.enable = false;
        efi = {
          canTouchEfiVariables = false;
          efiSysMountPoint = "/boot";
        };
        timeout = 2;
        grub = {
          enable = true;
          efiSupport = true;
          efiInstallAsRemovable = true;
        };
      };
    };
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  };
}
