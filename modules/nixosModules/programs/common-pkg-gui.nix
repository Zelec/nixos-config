{self, ...}: {
  flake.nixosModules.common-pkg-gui = {pkgs, ...}: {
    imports = with self.nixosModules; [
      chromium
      discord
      firefox
      hunspell
      obs
      vscode
    ];
    environment.systemPackages = with pkgs; [
      deluge-gtk
      element-desktop
      finamp
      gocryptfs
      helvum
      moonlight-qt
      papirus-icon-theme
      pavucontrol
      prismlauncher
      protonvpn-gui
      rclone
      remmina
      source-code-pro
      teamspeak6-client
      tela-icon-theme
      uhk-agent
      uhk-udev-rules
      vulkan-loader
      vulkan-tools
      zoom-us

      pkgs.unstable.ventoy-full-qt
    ];

    # Enable appimage use on NixOS
    programs.appimage.binfmt = true;
  };
}
