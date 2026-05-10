{
  flake.nixosModules.btrfs-scrub = {lib, ...}: {
    services.btrfs.autoScrub = {
      enable = true;
      interval = "weekly";
      fileSystems = lib.mkOptionDefault ["/"];
    };
  };
}
