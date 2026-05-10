#
# TimeDial.timeguard.ca
# Custom Homelab Server
# AMD Ryzen 3950x
# NVidia 4060 Ti 16GB
#
{
  inputs,
  self,
  lib,
  ...
}: {
  flake = {
    nixosConfigurations.TimeDial = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        self.nixosModules.hostTimeDial
      ];
    };
    nixosModules.hostTimeDial = {
      config,
      pkgs,
      ...
    }: {
      imports = with self.nixosModules; [
        # Base setup
        base
        # Desktop
        kde
        # Hardware
        bluetooth
        nvidia
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
        btrbk-mass-backup
        flatpak
        forgejo-runner
        printing
        sunshine
        syncthing
        tailscale
        tlp
        # Virtualisation
        docker
        libvirt
        # Containers
        containers-plex
      ];

      system.stateVersion = "24.05";
      networking.hostName = "TimeDial";

      preferences.syncthing.guiAddress = "0.0.0.0";
      preferences.nvidia.enablePatch = true;
      preferences.docker.nvidia.enable = true;
      preferences.locate.interval = "22:15";
      # 1:00 AM
      preferences.containers-watchtower.schedule = "0 0 1 * * *";

      boot = {
        binfmt.emulatedSystems = ["aarch64-linux"];
        loader = {
          # Systemd boot for quick & simple booting
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
        kernel.sysctl = {
          "net.ipv4.ip_forward" = 1;
          "net.ipv6.conf.all.forwarding" = 1;
        };
        plymouth = {
          enable = true;
          # Stylix manages this now
          # theme = "bgrt";
        };
        kernelParams = [
          # "udev.log_level=0"
        ];
      };

      environment = {
        systemPackages = with pkgs; [
          gocryptfs
          liquidctl
          source-code-pro
          vulkan-loader
          vulkan-tools
          protonmail-bridge-gui
        ];
        sessionVariables = {
          # LIBVA_DRIVER_NAME = "iHD"; # intel-media-driver
          # LIBVA_DRIVER_NAME = "i915"; # intel-vaapi-driver
          # VDPAU_DRIVER = "va_gl";
        };
      };

      xdg.portal.wlr.enable = true;
      security = {
        pam.services.sudo.fprintAuth = true;
        rtkit.enable = true;
      };
      programs = {
        virt-manager.enable = true;
        fuse.userAllowOther = true;
      };
      services = {
        # "/" is already included
        btrfs.autoScrub.fileSystems = lib.mkOptionDefault ["/media/NVMe_01" "/media/SSD_01" "/media/Storage_01"];
        fwupd.enable = true;
        fstrim.enable = true;
      };
    };
  };
}
