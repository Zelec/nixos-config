{
  flake.nixosModules.obs = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.preferences.obs;
  in {
    options.preferences.obs = {
      enableCUDA = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
    config = {
      programs.obs-studio = {
        enable = true;
        enableVirtualCamera = true;

        # optional Nvidia hardware acceleration
        package = (
          pkgs.obs-studio.override {
            cudaSupport = cfg.enableCUDA;
          }
        );

        plugins = with pkgs.obs-studio-plugins; [
          wlrobs
          obs-backgroundremoval
          obs-pipewire-audio-capture
          obs-vaapi #optional AMD hardware acceleration
          obs-gstreamer
          obs-vkcapture
        ];
      };
    };
  };
}
