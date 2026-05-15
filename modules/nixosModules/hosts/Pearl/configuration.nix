#
# Pearl.timeguard.ca
# Dell Optiplex 3050 MFF
# i3-7100u
# Intel HD 620 Graphics (Gen 9.5 Kaby Lake)
#
{
  inputs,
  self,
  ...
}: {
  flake = {
    nixosConfigurations.Pearl = inputs.nixpkgs-small.lib.nixosSystem {
      modules = [
        self.nixosModules.hostPearl
      ];
    };
    nixosModules.hostPearl = {
      config,
      pkgs,
      lib,
      ...
    }: {
      imports = with self.nixosModules; [
        # Base setup
        base
        hostServerCommon
        # Networking
        network-manager-resolved
        # Packages
        common-pkg
        # Services
        btrfs-scrub
        ddclient
        forgejo-runner
        renovate
        syncthing
        tailscale
        # Virtualisation
        docker
        libvirt
        # Containers
      ];
      system.stateVersion = "24.05";
      networking.hostName = "Pearl";

      preferences.syncthing.guiAddress = "0.0.0.0";
      # 5:00 AM
      preferences.containers-watchtower.schedule = "0 0 5 * * *";
      preferences.ddclient.configOptions = ''
        zone=tgdev.ca, base.tgdev.ca, base.timeguard.ca
        zone=timeguard.ca, pearl.timeguard.ca, peridot.timeguard.ca, timeportal.timeguard.ca
        zone=tgdev.ca, td.tgdev.ca
        zone=tgdev.net, td.tgdev.net
      '';
      # Since this box houses the git server, action runners need this to resolve
      preferences.forgejo-runner.containerOptions = "pearl.timeguard.ca:host-gateway";
      preferences.forgejo-runner.cacheHost = "pearl.timeguard.ca";
      preferences.forgejo-runner.enablePrivilegedLabels = false;

      networking.firewall = {
        allowedTCPPorts = [
          # Minecraft
          25565
          19132
          # Forgejo Alt SSH
          2222
        ];
        allowedUDPPorts = [
          # Minecraft
          25565
          19132
        ];
      };

      # Bootloader.
      boot.loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
        timeout = 5;
      };
      boot.kernel.sysctl = {
        "net.ipv4.ip_forward" = 1;
        "net.ipv6.conf.all.forwarding" = 1;
      };

      environment.systemPackages = with pkgs; [
        curl
        nano
        vim
        wget
      ];
    };
  };
}
