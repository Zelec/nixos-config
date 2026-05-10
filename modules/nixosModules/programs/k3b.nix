# KDE Disk Burner
# Normal k3b package fails to compile
# kdePackages.k3b actually installs
# Need to add /run/wrappers/bin into paths under
# Settings -> Configure K3b -> Search Path
# https://github.com/NixOS/nixpkgs/issues/19154#issuecomment-2468912624
{
  flake.nixosModules.k3b = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      kdePackages.k3b
    ];
    services.udisks2.enable = true;
    security.wrappers = {
      cdrdao = {
        setuid = true;
        owner = "root";
        group = "cdrom";
        permissions = "u+wrx,g+x";
        source = "${pkgs.cdrdao}/bin/cdrdao";
      };
      cdrecord = {
        setuid = true;
        owner = "root";
        group = "cdrom";
        permissions = "u+wrx,g+x";
        source = "${pkgs.cdrtools}/bin/cdrecord";
      };
    };
  };
}
