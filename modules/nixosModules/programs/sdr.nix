{
  flake.nixosModules.sdr = {
    config,
    pkgs,
    ...
  }: {
    hardware.rtl-sdr.enable = true;
    users.users.${config.preferences.user.name}.extraGroups = ["plugdev" "dialout"];
    environment.systemPackages = with pkgs; [
      chirp
      glfw
      gnuradio
      gqrx
      libusb1
      rtl-sdr
      sdrpp
      wayland-protocols
    ];
  };
}
