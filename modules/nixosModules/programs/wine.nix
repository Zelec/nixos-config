{
  flake.nixosModules.wine = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      wineWowPackages.stableFull
      winetricks
    ];
  };
}
