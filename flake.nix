{
  description = "Zelec's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # disko = {
    #   url = "github:nix-community/disko";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    nixos-06cb-009a-fingerprint-sensor = {
      url = "github:ahbnr/nixos-06cb-009a-fingerprint-sensor?ref=58a01fe62f5a71778bffaeb9929a118b4be0d222";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, vscode-server, nixos-06cb-009a-fingerprint-sensor, ... }: 
  let
    inputs = { 
      inherit home-manager nixpkgs nixpkgs-unstable; 
    };
    genPkgs = system: import nixpkgs {
      inherit system; 
      config.allowUnfree = true; 
    };
    genUnstablePkgs = system: import nixpkgs-unstable {
      inherit system; 
      config.allowUnfree = true; 
    };

    nixosSystem = system: hostname: username:
      let
        pkgs = genPkgs system;
        unstablePkgs = genUnstablePkgs system;
      in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit pkgs unstablePkgs nixos-06cb-009a-fingerprint-sensor;
            # lets us use these things in modules
            customArgs = {
              inherit system hostname username pkgs unstablePkgs;
            };
          };
          modules = [
            #disko.nixosModules.disko
            #./hosts/nixos/${hostname}/disko-config.nix

            ./hosts/${hostname}/configuration.nix

            vscode-server.nixosModules.default
            nixos-06cb-009a-fingerprint-sensor.nixosModules.open-fprintd
            nixos-06cb-009a-fingerprint-sensor.nixosModules.python-validity
            home-manager.nixosModules.home-manager {
              networking.hostName = hostname;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = { imports = [ ./home/${username}.nix ]; };
            }
            ./hosts/common/nix-common.nix
          ];
        };
  in
  {
    nixosConfigurations = {
      TimeWarp = nixosSystem "x86_64-linux" "TimeWarp" "zelec";
       # use this for a blank ISO + disko to work
      nixos = nixosSystem "x86_64-linux" "nixos" "zelec";
    };
  };
}
