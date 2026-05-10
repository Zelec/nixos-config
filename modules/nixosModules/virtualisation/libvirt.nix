{
  flake.nixosModules.libvirt = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      vagrant
    ];
    virtualisation.spiceUSBRedirection.enable = true;
    virtualisation.libvirtd = {
      enable = true;
      qemu = let
        # To help simplify path typing
        # Full path example "/run/libvirt/nix-ovmf/edk2-x86_64-secure-code.fd"
        edk2f = "/run/libvirt/nix-ovmf/edk2";
      in {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        verbatimConfig = ''
          namespaces = []
          nvram = [ "${edk2f}-aarch64-code.fd:${edk2f}-arm-vars.fd", "${edk2f}-arm-code.fd:${edk2f}-arm-vars.fd", "${edk2f}-x86_64-secure-code.fd:${edk2f}-i386-vars.fd", "${edk2f}-x86_64-code.fd:${edk2f}-i386-vars.fd", "${edk2f}-i386-secure-code.fd:${edk2f}-i386-vars.fd", "${edk2f}-i386-code.fd:${edk2f}-i386-vars.fd" ]
        '';
      };
    };
  };
}
