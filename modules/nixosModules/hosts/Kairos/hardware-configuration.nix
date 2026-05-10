{inputs, ...}: {
  flake.nixosModules.hostKairos = {
    config,
    lib,
    pkgs,
    modulesPath,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
      inputs.nixos-hardware.nixosModules.common-cpu-intel
      inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
      "${inputs.nixos-hardware}/common/cpu/intel/haswell"
      "${inputs.nixos-hardware}/common/gpu/intel/haswell"
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
      resumeDevice = "/dev/Kairos-vg/swap";
      loader = {
        # Systemd boot for quick & simple booting
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
        timeout = 0; # Disable bootup prompt unless Spacebar is held
      };
      initrd = {
        systemd.enable = true;
        availableKernelModules = [
          "xhci_pci"
          "ehci_pci"
          "ahci"
          "uas"
          "sd_mod"
          "rtsx_pci_sdmmc"
        ];
        kernelModules = [
          #"i915"
        ];
      };
      plymouth = {
        enable = true;
        # Stylix manages this now
        # theme = "bgrt";
      };
      kernelParams = [
        "quiet"
        "udev.log_level=0"
        "splash"
        # "i915.enable_guc=3"
        # "i915.enable_fbc=1"
        # Disable "Panel Self Refresh".  Fix random freezes.
        # "i915.enable_psr=0"
        # "i915.fastboot=1"
      ];
    };

    networking.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
