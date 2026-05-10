# Default modules for all systems
{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.base = {
    imports = [
      inputs.copyparty.nixosModules.default
      inputs.disko.nixosModules.disko
      inputs.home-manager.nixosModules.home-manager
      inputs.nix-flatpak.nixosModules.nix-flatpak
      inputs.nix-index-database.nixosModules.default
      inputs.sops-nix.nixosModules.sops
      inputs.stylix.nixosModules.stylix

      # Default internal modules used by all machines
      self.nixosModules.common-pkg
      self.nixosModules.openssh
      self.nixosModules.locate
      self.nixosModules.stylix
    ];
    config = {
      programs.nix-index-database.comma.enable = true;
      services.fstrim.enable = true;
    };
  };
}
