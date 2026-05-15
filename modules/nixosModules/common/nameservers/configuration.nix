# Common Nameserver boilerplate
{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.hostNSCommon = {
    config,
    pkgs,
    lib,
    ...
  }: let
    cfg = config.preferences.nameserver-common;
  in {
    imports = with self.nixosModules; [
      # Base setup
      base
      hostServerCommon
      # Packages
      common-pkg
      # Services
      btrfs-scrub
      coredns
      tailscale
      # System
      autoUpgrade
    ];
    options.preferences.nameserver-common = {
      networking = {
        interface = lib.mkOption {
          type = lib.types.str;
          default = "enp1s0";
        };
        address = lib.mkOption {
          type = lib.types.str;
          default = "10.23.23.2";
        };
        prefixLength = lib.mkOption {
          type = lib.types.int;
          default = 24;
        };
        defaultGateway = lib.mkOption {
          type = lib.types.str;
          default = "10.23.23.1";
        };
      };
    };
    config = {
      environment.systemPackages = with pkgs; [
        curl
        git
        just
        vim
        wget
      ];
      networking = {
        firewall.allowedTCPPorts = [
          # DNS
          53
        ];
        firewall.allowedUDPPorts = [
          # DNS
          53
        ];
        nameservers = ["1.1.1.1" "1.0.0.1" "8.8.8.8" "8.8.4.4"];
        interfaces.${cfg.networking.interface} = {
          ipv4.addresses = [
            {
              address = cfg.networking.address;
              prefixLength = cfg.networking.prefixLength;
            }
          ];
        };
        defaultGateway = {
          address = cfg.networking.defaultGateway;
          interface = cfg.networking.interface;
        };
      };
    };
  };
}
