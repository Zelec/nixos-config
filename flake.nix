{
  description = "Zelec's NixOS Flake";

  nixConfig = {
    extra-substituters = ["https://attic.tgdev.net/zelec-nixos-config?priority=30"];
    extra-trusted-public-keys = ["zelec-nixos-config:KqD+Mz2I+GGcubvNcAyeq0tP7pitJRedwmKPzm5vcnQ="];
  };

  inputs = {
    # Baseline flake boilerplate
    # Nixpkgs base
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-small.url = "github:nixos/nixpkgs?ref=nixos-25.11-small";
    # Flake Parts for dendritic patterning
    flake-parts.url = "github:hercules-ci/flake-parts";
    # Import Tree to simplify nix file loading
    import-tree.url = "github:vic/import-tree";

    # Attic, Nix Binary Cache server
    attic.url = "github:zhaofengli/attic";
    attic.inputs.nixpkgs.follows = "nixpkgs";
    # Copyparty, portable file server
    copyparty.url = "github:9001/copyparty";
    copyparty.inputs.nixpkgs.follows = "nixpkgs";
    # Disko, managed disk partitioning in Nix
    disko.url = "github:nix-community/disko?ref=v1.13.0";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    # Home Manager, Dotfile manager
    home-manager.url = "github:nix-community/home-manager?ref=release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # Nix-Flatpak, Flatpak management via Nix
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    # Nix-Index-Database, Search for files in nixpkgs, and wrapper for comma
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    # Nix-VSCode-Extensions, used to manage VSCode/VSCodium extensions
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";
    # NixOS Hardware, community sourced hardware recommended defaults
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # Nix User Repo, Used by Firefox managed addons
    nur.url = "github:nix-community/NUR";
    # NVIDIA Patch to auto patch NVENC and FBC
    nvidia-patch.url = "github:icewind1991/nvidia-patch-nixos";
    # Plasma Manager for managing KDE 6 settings
    plasma-manager.url = "github:nix-community/plasma-manager/trunk";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    # SOPS-Nix, Uses SOPS and the system's SSH keys for secure secret storage
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    # Pulls SSH keys from website
    ssh-keys = {
      url = "https://keys.tgdev.net";
      flake = false;
    };
    # Work SSH keys
    ssh-keys-work = {
      url = "https://keys-work.tgdev.net";
      flake = false;
    };
    # Stylix, Unified
    stylix.url = "github:danth/stylix?ref=release-25.11";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    # Private flake for semi-private eval time inputs
    private.url = "git+ssh://git@ssh-git.tgdev.net:2222/Zelec/nixos-config-private.git";
  };
  # Main entrypoint, uses import-tree to load all nix files under ./modules
  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);
}
