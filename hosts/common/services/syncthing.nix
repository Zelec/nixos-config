{ lib, inputs, ... }:
{
  services.syncthing = {
    enable = lib.mkDefault true;
    user = lib.mkDefault "zelec";
    dataDir = lib.mkDefault "/home/zelec/Sync";
    configDir = lib.mkDefault "/home/zelec/.config/syncthing";
  }; 
}