{inputs, ...}: {
  flake.nixosModules.hostNixOS-Router = {
    config,
    lib,
    pkgs,
    modulesPath,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
      "${inputs.nixos-hardware}/common/cpu/intel/haswell"
      "${inputs.nixos-hardware}/common/gpu/intel/haswell"
      inputs.nixos-hardware.nixosModules.common-pc-ssd
    ];
    boot = {
      initrd = {
        availableKernelModules = ["sd_mod" "sr_mod"];
        kernelModules = [];
      };
      kernelModules = ["kvm-intel"];
      extraModulePackages = [];
    };

    networking.useDHCP = lib.mkDefault true;
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  };
}
