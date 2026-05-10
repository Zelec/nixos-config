# This module sucks (By that I mean I forget I have this installed on all of my machines
# and I fallback to using good ol `find / | grep 'whatever-im-looking-for`), I should probably get rid of it
# since it causes problems for my backup system.
{
  flake.nixosModules.locate = {
    config,
    pkgs,
    lib,
    ...
  }: let
    cfg = config.preferences.locate;
  in {
    options.preferences.locate = {
      interval = lib.mkOption {
        type = lib.types.str;
        default = "hourly";
      };
    };
    config.services.locate = {
      enable = true;
      package = pkgs.plocate;
      interval = cfg.interval;
      pruneFS = lib.mkOptionDefault [
        "fuse.gocryptfs"
      ];
      prunePaths = lib.mkOptionDefault [
        "/media/btrfsroots"
        "/media/secureArchiveStorage"
      ];
    };
  };
}
