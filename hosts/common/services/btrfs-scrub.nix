{ lib, inputs, ... }:
{
  services.btrfs = {
    autoScrub = {
      enable = lib.mkDefault true;
      interval = lib.mkDefault "weekly";
    };
  };
}