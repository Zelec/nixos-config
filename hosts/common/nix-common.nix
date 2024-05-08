{ lib, inputs, pkgs, unstablePkgs, ... }:
let
  inherit (inputs) nixpkgs nixpkgs-unstable;
in
{
  time.timeZone = lib.mkDefault "America/Toronto";
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
    };
    # Automatic Garbage Collection of older NixOS Generations
    gc = {
      automatic = lib.mkDefault true;
      dates = lib.mkDefault "weekly";
      options = lib.mkDefault "--delete-older-than 15";
    };
  };
  nixpkgs.config.allowUnfree = lib.mkDefault true;
}