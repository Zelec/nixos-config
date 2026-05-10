# Build the system config and switch to it when running `just` with no args
default: switch
apply: switch

default_args := "--sudo --ask-sudo-password --use-substitutes"
hostname := `hostname | cut -d "." -f 1`

### linux
# Build the NixOS configuration without switching to it
[linux]
build target_host=hostname flags="":
	nixos-rebuild build --flake ./#{{target_host}} {{flags}}

# Dry-Build the NixOS configuration without switching to it
[linux]
dry-build target_host=hostname flags="":
	nixos-rebuild dry-build --flake ./#{{target_host}} {{flags}}

# Build the NixOS config with the --show-trace flag set
[linux]
trace target_host=hostname: (build target_host "--show-trace")

# Build the NixOS configuration and switch to it.
[linux]
switch target_host=hostname flags="":
  nixos-rebuild switch --flake ./#{{target_host}} {{default_args}} {{flags}}

# Build the NixOS configuration locally and push/switch a remote host.
[linux]
switch-remote target_host=hostname flags="":
  nixos-rebuild switch --flake ./#{{target_host}} --target-host {{target_host}} {{default_args}} {{flags}}

# Build the NixOS configuration and switch to it on boot.
[linux]
boot target_host=hostname flags="":
  nixos-rebuild boot --flake ./#{{target_host}} {{default_args}} {{flags}}

# Build the NixOS configuration locally and push/switch a remote host on boot.
[linux]
boot-remote target_host=hostname flags="":
  nixos-rebuild boot --flake ./#{{target_host}} --target-host {{target_host}} {{default_args}} {{flags}}

# Run disko config with flake execution
[linux]
disko-format target_host=hostname:
  sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/v1.13.0 -- --mode disko --flake ./#{{target_host}}

# Mount disk for troubleshooting
[linux]
disko-mount target_host=hostname:
  sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/v1.13.0 -- --mode mount --flake ./#{{target_host}}

# Install NixOS config remotely
[linux]
nixos-anywhere target_host ssh_target:
  nix run github:nix-community/nixos-anywhere -- --flake ./#{{target_host}} {{ssh_target}}

# Builds and pushes to Attic
[linux]
attic-build target_host=hostname:
  just build "{{target_host}}"
  attic push zelec-nixos-config ./result


# Builds and pushes attic build artifacts for all hosts
[linux]
attic-build-all:
  #!/usr/bin/env bash
  set -euxo pipefail
  flakes=($(nix flake show --json | jq -r '.nixosConfigurations | keys[]'))
  for i in "${flakes[@]}"; do
    just attic-build "${i}"
  done

# Validates nix config
validate:
  nix flake check --option abort-on-warn false

# Update flake inputs to their latest revisions
update:
  nix flake update

cleanup:
  rm -f ./result*

# Garbage collect old OS generations and remove stale packages from the nix store
gc generations="5":
  nix-env --delete-generations {{generations}}
  nix-store --gc
  nix-collect-garbage -d
