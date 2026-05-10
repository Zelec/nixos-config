{
  flake.nixosModules.printing = {pkgs, ...}: {
    services.printing = {
      enable = true;
      drivers = with pkgs; [
        brlaser
        epson-escpr
        epson-escpr2
        gutenprint
        gutenprintBin
        hplip
        mfcl3770cdwlpr
        splix
      ];
    };
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
