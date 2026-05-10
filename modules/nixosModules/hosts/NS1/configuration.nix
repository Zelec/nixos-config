{
  inputs,
  self,
  ...
}: {
  flake = {
    nixosConfigurations.NS1 = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        self.nixosModules.hostNS1
      ];
    };
    nixosModules.hostNS1 = {pkgs, ...}: {
      imports = with self.nixosModules; [
        # Common Nameserver Module
        hostNSCommon
      ];
      system.stateVersion = "24.05";
      networking.hostName = "NS1";
      environment.systemPackages = with pkgs; [];
      preferences.nameserver-common.networking = {
        interface = "enp1s0";
        address = "10.23.23.2";
        prefixLength = 24;
        defaultGateway = "10.23.23.1";
      };
    };
  };
}
