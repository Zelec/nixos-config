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
          ddrescue
          glances
          gparted
          gptfdisk
          kdePackages.plasma-pa
          lxappearance
          magic-wormhole
          ncdu
          nvme-cli
          papirus-icon-theme
          pavucontrol
          plymouth
          source-code-pro
          tela-icon-theme
          tmux
          vulkan-loader
          vulkan-tools
        ];
      };
      programs = {
        virt-manager.enable = true;
      };
      security = {
        rtkit.enable = true;
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
      services = {
        fstrim.enable = true;
        libinput.enable = true;
        xserver.enable = true;
      };
      xdg.portal.wlr.enable = true;
    };
  };
}
