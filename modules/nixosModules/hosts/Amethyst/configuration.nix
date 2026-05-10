#
# Amethyst.timeguard.ca
# OVH VPS-2 Server
# 6 vCores
# 12 GB RAM
# 100 GB SSD Storage
#
{
  inputs,
  self,
  ...
}: {
  flake = {
    nixosConfigurations.Amethyst = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        self.nixosModules.hostAmethyst
      ];
    };
    nixosModules.hostAmethyst = {pkgs, ...}: {
      imports = with self.nixosModules; [
        # Base setup
        base
        hostServerCommon
        # Networking
        # network-manager-resolved
        # Packages
        common-pkg
        # Services
        btrfs-scrub
        forgejo-runner
        tailscale
        # Virtualisation
        docker
        libvirt
        # Virtualisation Containers
        containers-caddy-subsite-webfinger
        containers-matrix-backend-call-support
        # containers-vlmcsd
      ];
      system.stateVersion = "24.05";
      networking.hostName = "Amethyst";

      boot.kernel.sysctl = {
        "net.ipv4.ip_forward" = 1;
        "net.ipv6.conf.all.forwarding" = 1;
      };
      preferences.forgejo-runner.enableGenericLabels = false;
      preferences.forgejo-runner.enablePrivilegedLabels = false;

      environment.systemPackages = with pkgs; [
        curl
        nano
        vim
        wget
      ];
    };
  };
}
