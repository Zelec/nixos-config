#
# Kairos.timeguard.ca
# Lenovo x240 Thinkpad
# i5-4200u
# Intel HD 4400 Graphics (Gen 4 Haswell)
#
{
  inputs,
  self,
  ...
}: {
  flake = {
    nixosConfigurations.Kairos = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        self.nixosModules.hostKairos
      ];
    };
    nixosModules.hostKairos = {pkgs, ...}: {
      imports = with self.nixosModules; [
        # Base setup
        base
        # Desktop
        kde
        # Hardware
        bluetooth
        # Networking
        network-manager-resolved
        # Packages
        adb
        common-pkg
        common-pkg-gui
        k3b
        sdr
        # Services
        btrfs-scrub
        flatpak
        printing
        tailscale
        syncthing
        tlp
        # Virtualisation
        docker
        libvirt
      ];

      system.stateVersion = "24.05";
      networking.hostName = "Kairos";

      # Every 6 hours
      preferences.containers-watchtower.schedule = "0 0 */6 * * *";
    };
  };
}
