{ lib, inputs, pkgs, unstablePkgs, ... }:
let
  inherit (inputs) nixpkgs nixpkgs-unstable;
in
{
  environment.systemPackages = with pkgs; [
    ansible
    bash
    bitwarden-cli
    borgbackup
    borgmatic
    coreutils
    curl
    devbox
    dig
    docker-compose
    ffmpeg
    git
    glances
    gnumake
    go
    htop
    jq
    mosh
    pciutils
    smartmontools
    terraform
    tmux
    unzip
    usbutils
    vim
    watch
    wget
    wireguard-tools
    zstd

    # # requires nixpkgs.config.allowUnfree = true;
    # vscode-extensions.ms-vscode-remote.remote-ssh
  ];
}