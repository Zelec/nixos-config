#
# Chronos.timeguard.ca
# Lenovo T490 Thinkpad
# i7-8665u
#
{
  inputs,
  self,
  ...
}: {
  flake = {
    nixosConfigurations.Chronos = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        self.nixosModules.hostChronos
      ];
    };
    nixosModules.hostChronos = {pkgs, ...}: {
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
        steam
        wine
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
        # Virtualisation Containers
      ];
      system.stateVersion = "24.05";
      networking.hostName = "Chronos";

      # Every 6 hours
      preferences.containers-watchtower.schedule = "0 0 */6 * * *";

      environment = {
        systemPackages = with pkgs; [
          vulkan-loader
          vulkan-tools
        ];
      };

      xdg.portal.wlr.enable = true;
      security = {
        pam.services.sudo.fprintAuth = true;
        rtkit.enable = true;
      };
      programs = {
        virt-manager.enable = true;
      };
      services = {
        fstrim.enable = true;
        fwupd.enable = true;
        libinput.enable = true;
        printing.enable = true;
        udisks2.enable = true;
        xserver.enable = true;
      };
    };
  };
}
