{inputs, ...}: {
  flake.nixosModules.hostChronos = {
    config,
    lib,
    pkgs,
    modulesPath,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
      "${inputs.nixos-hardware}/common/cpu/intel/whiskey-lake"
      "${inputs.nixos-hardware}/common/gpu/intel/whiskey-lake"
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t490
      inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
    ];
    hardware = {
      bluetooth = {
        enable = true;
        powerOnBoot = true;
      };
    };
    boot = {
      kernelPackages = pkgs.linuxPackages_zen;
      kernelModules = ["kvm-intel"];
      extraModulePackages = [];
      resumeDevice = "/dev/Chronos-vg/swap";
      loader = {
        # Systemd boot for quick & simple booting
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
        timeout = 0; # Disable bootup prompt unless Spacebar is held
      };
      initrd = {
        availableKernelModules = [
          "xhci_pci"
          "nvme"
          "uas"
          "sd_mod"
          "rtsx_pci_sdmmc"
        ];
        kernelModules = [
          "dm-snapshot"
        ];
        systemd.enable = true;
      };
      plymouth = {
        enable = true;
      };
      kernelParams = [
        "quiet"
        "udev.log_level=0"
        "splash"
      ];
    };
    virtualisation.docker.storageDriver = "btrfs";
    networking.useDHCP = lib.mkDefault true;
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
