#
# Sophos XG Firewall
# Experiment box
#
{
  inputs,
  self,
  ...
}: {
  flake = {
    nixosConfigurations.NixOS-Router = inputs.nixpkgs-small.lib.nixosSystem {
      modules = [
        self.nixosModules.hostNixOS-Router
      ];
    };
    nixosModules.hostNixOS-Router = {pkgs, ...}: {
      imports = with self.nixosModules; [
        # Base setup
        base
        # Packages
        common-pkg
        # Services
        btrfs-scrub
        tailscale
        # Virtualisation
        docker
        libvirt
      ];
      system.stateVersion = "24.05";
      networking.hostName = "NixOS-Router";

      boot = {
        loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
          timeout = 5;
        };
        initrd = {
          systemd.enable = true;
          kernelModules = [
            # "i915"
          ];
        };
        kernelParams = [
          # "udev.log_level=0"
        ];
      };
      services = {
        openssh.enable = true;
        tailscale.enable = true;
        fwupd.enable = true;
        fstrim.enable = true;
        hardware = {
          lcd.server = {
            enable = true;
            extraConfig = ''
              Hello="NixOS"
              Hello="Router"
              GoodBye="Goodbye"
              Driver=mtc_s16209x
              WaitTime=5
              TitleSpeed=5
              ServerScreen=on
              Backlight=open
              Heartbeat=open

              [mtc_s16209x]
              Device=/dev/ttyS1
              Size=16x2
              Brightness=255
              Reboot=yes

              [menu]
              MenuKey="Escape"
              EnterKey="Enter"
              UpKey="Up"
              DownKey="Down"
              LeftKey="Left"
              RightKey="Right"
            '';
          };
          lcd.client = {
            enable = true;
            extraConfig = ''
              [About]
              # Show screen
              Active=false
            '';
          };
        };
      };
      environment.systemPackages = with pkgs; [
        colmena
        curl
        git
        just
        lcdproc
        vim
        wget
      ];
    };
  };
}
