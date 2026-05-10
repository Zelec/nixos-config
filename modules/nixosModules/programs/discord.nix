{
  flake.nixosModules.discord = {
    config,
    pkgs,
    ...
  }: {
    environment.systemPackages = with pkgs; [
      arrpc
    ];
    systemd.packages = with pkgs; [
      arrpc
    ];
    home-manager.users.${config.preferences.user.name} = {
      services.arrpc = {
        enable = true;
        package = pkgs.arrpc;
        systemdTarget = "graphical-session.target";
      };
      programs.vesktop = {
        enable = true;
        package = pkgs.unstable.vesktop.override {
          withTTS = true;
        };
        vencord.settings = {
          autoUpdate = true;
          autoUpdateNotification = true;
          notifyAboutUpdates = true;
          hardwareAcceleration = true;
          discordBranch = "stable";
          plugins = {
            ClearURLs.enabled = true;
            FixYoutubeEmbeds.enabled = true;
            YoutubeAdblock.enabled = true;
          };
        };
      };
    };
  };
}
