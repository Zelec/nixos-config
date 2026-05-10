{self, ...}: {
  flake.nixosModules.kde = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      self.nixosModules.bluetooth
      self.nixosModules.pipewire
      self.nixosModules.printing
    ];
    environment.systemPackages = with pkgs.kdePackages; [
      ark
      discover
      dolphin
      filelight
      gwenview
      isoimagewriter
      k3b
      kcalc
      kcharselect
      kclock
      kcolorchooser
      kdenlive
      kfind
      kolourpaint
      ksystemlog
      partitionmanager
      sddm-kcm
      spectacle
    ];
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
    services = {
      displayManager = {
        defaultSession = "plasma";
        sddm = {
          enable = true;
          wayland.enable = true;
        };
        autoLogin = {
          enable = true;
          user = config.preferences.user.name;
        };
      };
      desktopManager.plasma6.enable = true;
      fstrim.enable = true;
      fwupd.enable = true;
      gvfs.enable = true;
      libinput.enable = true;
    };
    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.kdePackages.xdg-desktop-portal-kde
        pkgs.xdg-desktop-portal-gtk
      ];
      config.common.default = ["kde" "gtk"];
      xdgOpenUsePortal = true;
    };
  };
}
