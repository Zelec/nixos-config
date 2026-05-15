# Default NixOS Configuration and junk
{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.base = {
    config,
    pkgs,
    lib,
    ...
  }: let
    defaultOverlays = [
      inputs.copyparty.overlays.default
      inputs.nix-vscode-extensions.overlays.default
      inputs.nur.overlays.default
      inputs.nvidia-patch.overlays.default
    ];
    baseNixPkgConfig = {
      allowUnfree = true;
      permittedInsecurePackages = [
        # Ventoy is marked as insecure due to it's licensing problems and blob use
        inputs.nixpkgs-unstable.legacyPackages.x86_64-linux.ventoy-full-qt.name
        # Required for Lutris atm, as mbedtls marked as unmaintained now.
        inputs.nixpkgs.legacyPackages.x86_64-linux.mbedtls.name
        inputs.nixpkgs.legacyPackages.x86_64-linux.mbedtls_2.name
      ];
    };
  in {
    options.preferences = {
      timeZone = lib.mkOption {
        type = lib.types.str;
        default = "America/Toronto";
      };
    };
    config = lib.mkMerge [
      {
        nixpkgs = {
          config = baseNixPkgConfig;
          overlays =
            defaultOverlays
            ++ [
              (final: prev: {
                unstable = import inputs.nixpkgs-unstable {
                  system = prev.stdenv.hostPlatform.system;
                  config = baseNixPkgConfig;
                  overlays = defaultOverlays;
                };
              })
            ];
        };
        sops.defaultSopsFile = ../../../secrets.yml;
        sops.secrets.root_hashed_password.neededForUsers = true;
        users.users.root.hashedPasswordFile = config.sops.secrets.root_hashed_password.path;
        sops.secrets.nix_netrc_file = {
          owner = "root";
          path = "/etc/nix/netrc";
          # Just for extra safety
          mode = "0600";
        };
        users.mutableUsers = false;
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        fonts.enableDefaultPackages = true;
        i18n = {
          defaultLocale = "en_CA.UTF-8";
          supportedLocales = [
            "en_CA.UTF-8/UTF-8"
            "en_US.UTF-8/UTF-8"
            "en_GB.UTF-8/UTF-8"
          ];
        };
        time.timeZone = config.preferences.timeZone;
        nix = {
          settings = {
            experimental-features = ["nix-command" "flakes"];
            warn-dirty = false;
            trusted-users = [
              "root"
              "@wheel"
            ];
            substituters = [
              "https://attic.tgdev.net/zelec-nixos-config?priority=30"
            ];
            trusted-public-keys = [
              "zelec-nixos-config:KqD+Mz2I+GGcubvNcAyeq0tP7pitJRedwmKPzm5vcnQ="
            ];
          };
          # Pin nixpkgs to the flake input for nix-shell
          nixPath = ["nixpkgs=${inputs.nixpkgs}"];
          # Automatic Garbage Collection of older NixOS Generations
          gc = {
            automatic = true;
            dates = "daily";
            options = "--delete-older-than 15d";
          };
          # Automatic consolidation of the nix store
          optimise = {
            automatic = true;
            dates = [
              "03:45"
            ];
          };
        };
        programs = {
          bash.completion.enable = true;
          dconf.enable = true;
          nix-ld = {
            enable = true;
            package = pkgs.nix-ld;
            libraries = with pkgs; [
              icu
              icu.dev
              sdl3
            ];
          };
        };
        environment.systemPackages = with pkgs; [
          nixd
        ];
        users.users."root".openssh.authorizedKeys.keyFiles = [inputs.ssh-keys.outPath];
        networking.firewall.enable = lib.mkDefault false;

        security.polkit.enable = true;
      }
      (lib.mkIf (config.services.displayManager.enable) {
        programs.ssh.startAgent = false;
        services.gnome.gcr-ssh-agent.enable = true;
      })
      (lib.mkIf (! config.services.displayManager.enable) {
        programs.ssh.startAgent = true;
        services.gnome.gcr-ssh-agent.enable = false;
      })
    ];
  };
}
