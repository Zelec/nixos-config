{
  flake.nixosModules.flatpak = {...}: {
    services = {
      flatpak = {
        enable = true;
        remotes = [
          {
            name = "flathub";
            location = "https://flathub.org/repo/flathub.flatpakrepo";
          }
        ];
        # TODO: I should get rid of this and make my installs use good ol' nixpkgs instead
        # Don't get me wrong flatpak is great for oneoffs, or certain programs who only want to be
        # distributed via flatpaks (Such as bottles)
        # But I really should embrace nixpkgs for most of my software needs.
        packages = [
          "com.rustdesk.RustDesk"
          "com.usebottles.bottles"
          "in.cinny.Cinny"
          "org.gimp.GIMP"
          "org.kde.kcalc"
          "org.kde.kdenlive"
          "org.kde.kpat"
          "org.kde.krita"
          "org.libreoffice.LibreOffice"
          "org.mozilla.Thunderbird"
          "org.signal.Signal"
          "org.videolan.VLC"
        ];
        update.auto = {
          enable = true;
          onCalendar = "weekly";
        };
        uninstallUnused = true;
      };
      fwupd.enable = true;
      packagekit.enable = true;
    };
  };
}
