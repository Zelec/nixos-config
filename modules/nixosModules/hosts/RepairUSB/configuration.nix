#
# RepairUSB
# Custom repair USB Stick
# Samsung BAR Plug 256GB USB Drive
#
{
  inputs,
  self,
  ...
}: {
  flake = {
    nixosConfigurations.RepairUSB = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        self.nixosModules.hostRepairUSB
      ];
    };
    nixosModules.hostRepairUSB = {pkgs, ...}: {
      imports = with self.nixosModules; [
        # Base setup
        base
        # Desktop
        sway
        # Networking
        network-manager-resolved
        # Packages
        adb
        common-pkg
        common-pkg-gui
        k3b
        wine
        # Services
        flatpak
        printing
        tailscale
        # Virtualisation
        docker
        libvirt
      ];

      system.stateVersion = "24.05";
      networking.hostName = "RepairUSB";

      # Every 6 hours
      preferences.containers-watchtower.schedule = "0 0 */6 * * *";

      boot = {
        loader = {
          # Systemd boot for quick & simple booting
          systemd-boot.enable = false;
          efi = {
            canTouchEfiVariables = false;
            efiSysMountPoint = "/boot";
          };
          timeout = 5;
          grub = {
            enable = true;
            efiSupport = true;
            efiInstallAsRemovable = true;
          };
        };
        kernelParams = [
        ];
      };
      environment = {
        pathsToLink = ["/libexec"];
        systemPackages = with pkgs; [
          caffeine-ng
          ddrescue
          glances
          gparted
          lxappearance
          magic-wormhole
          nvme-cli
          pavucontrol
          tela-icon-theme
        ];
      };
      security = {
        sudo = {
          enable = true;
          extraRules = [
            {
              groups = ["wheel"];
              commands = [
                {
                  command = "ALL";
                  options = ["NOPASSWD"];
                }
              ];
            }
          ];
        };
      };
    };
  };
}
