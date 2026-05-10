{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.hostAion = {
    config,
    lib,
    pkgs,
    modulesPath,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
      "${inputs.nixos-hardware}/common/cpu/intel/comet-lake"
      "${inputs.nixos-hardware}/common/gpu/intel/comet-lake"
      inputs.nixos-hardware.nixosModules.common-cpu-intel
      inputs.nixos-hardware.nixosModules.common-pc-ssd
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
      resumeDevice = "/dev/Aion-vg/swap";
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
          "nvme"
          "usb_storage"
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
      ];
    };
    # services.xserver.dpi = 180;
    # environment.variables = {
    #   GDK_SCALE = "2";
    #   GDK_DPI_SCALE = "0.5";
    #   _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";
    # };

    networking.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
