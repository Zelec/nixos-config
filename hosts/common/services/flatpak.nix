{ lib, inputs, ... }:
{
  services = {
    flatpak.enable = lib.mkDefault true;
    fwupd.enable = lib.mkDefault true;
    packagekit.enable = lib.mkDefault true;
  };
}