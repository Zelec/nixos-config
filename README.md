# Zelec's NixOS Config

A cobbling of my NixOS Setup for my personal systems

Quite a bit of this is based on [IronicBadgets Nix Config Repo](https://github.com/ironicbadger/nix-config), [Vimjoyer's excellent videos](https://www.youtube.com/@vimjoyer), scrappings I've pulled together from the internet, and/or AI when I am just lost on how to make something work in Nix.

## Do note flake secrets for use in Nix at eval time are located outside the repo in a private flake

Before anyone freaks out, true secrets are handled within SOPS, anything that I don't mind being in plaintext in the nix store but would mind airing out on the public internet is moreso what I'm talking about here. If you need a sanitized copy of the private flake, don't hesitate to ask. But I wouldn't recommend you to use this flake as is without access to that private repo or access to my internal infra for build caching.

## Configuration Option Examples

```nix
{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.zelecSetup.packages.foobar;
in {
  options.zelecSetup.packages.foobar = {
    enable = lib.mkEnableOption "Enables Foobar User Config";
    packageBase = lib.mkOption {
      type = lib.types.pkgs;
      default = pkgs;
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = cfg.packageBase.foobar;
    };
  };
  config = lib.mkIf cfg.enable {
    services.foobar.enable =  true;
    services.foobar.package =  cfg.package;  
  };
}
```