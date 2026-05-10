{
  flake.nixosModules.common-pkg = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      alejandra
      ansible
      attic-client
      bash
      bitwarden-cli
      borgbackup
      borgmatic
      btdu
      btop
      cdrtools
      colmena
      copyparty
      coreutils
      cryptsetup
      curl
      devbox
      devenv
      dig
      distrobox
      docker-compose
      ffmpeg
      git
      glances
      gnumake
      go
      gocryptfs
      gptfdisk
      htop
      jq
      just
      lm_sensors
      minicom
      mosh
      ncdu
      nix-eval-jobs
      nix-fast-build
      nixos-install-tools
      ntfs3g
      pciutils
      polkit
      pulseaudio
      screen
      smartmontools
      sops
      terraform
      tmux
      unzip
      usbutils
      vim
      watch
      wget
      wireguard-tools
      zstd

      (python3.withPackages (
        ps: [
          ps.ansible
          ps.pip
          ps.requests
          ps.tkinter
        ]
      ))

      pkgs.unstable.yt-dlp
    ];
    programs.light.enable = true;
  };
}
