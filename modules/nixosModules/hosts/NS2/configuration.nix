{
  inputs,
  self,
  ...
}: {
  flake = {
    nixosConfigurations.NS2 = inputs.nixpkgs-small.lib.nixosSystem {
      modules = [
        self.nixosModules.hostNS2
      ];
    };
    nixosModules.hostNS2 = {pkgs, ...}: {
      imports = with self.nixosModules; [
        # Common Nameserver Module
        hostNSCommon
      ];
      system.stateVersion = "24.05";
      networking.hostName = "NS2";
      environment.systemPackages = with pkgs; [];
      preferences.nameserver-common.networking = {
        interface = "ens18";
        address = "10.23.23.3";
        prefixLength = 24;
        defaultGateway = "10.23.23.1";
      };
    };
  };
}
