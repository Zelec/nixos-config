#
# Aion.timeguard.ca
# Dell XPS 13 7390
# i7-10710U
# Intel UHD Graphics (Gen 10 Comet Lake)
#
{
  inputs,
  self,
  ...
}: {
  flake = {
    nixosConfigurations.Aion = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        self.nixosModules.hostAion
      ];
    };
    nixosModules.hostAion = {pkgs, ...}: {
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

        # # Host Specific Modules
        inputs.disko.nixosModules.default
      ];

      system.stateVersion = "24.05";
      networking.hostName = "Aion";

      # preferences.tlp.cpuMaxPerfBAT = 50;
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
        tpm2 = {
          enable = true;
          pkcs11.enable = true;
          tctiEnvironment.enable = true;
        };
      };
      programs = {
        virt-manager.enable = true;
      };
      services = {
        fwupd.enable = true;
        fstrim.enable = true;
        printing.enable = true;
        libinput.enable = true;
        xserver.enable = true;
      };
      virtualisation.docker.storageDriver = "btrfs";
    };
  };
}
