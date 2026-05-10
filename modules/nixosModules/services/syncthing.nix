{
  flake.nixosModules.syncthing = {
    config,
    lib,
    ...
  }: let
    cfg = config.preferences.syncthing;
  in {
    options.preferences.syncthing = {
      user = lib.mkOption {
        type = lib.types.str;
        default = "${config.preferences.user.name}";
      };
      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/home/${cfg.user}/Sync";
      };
      configDir = lib.mkOption {
        type = lib.types.str;
        default = "/home/${cfg.user}/.config/syncthing";
      };
      guiAddress = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
      };
      guiPort = lib.mkOption {
        type = lib.types.str;
        default = "8384";
      };
    };
    config = lib.mkMerge [
      {
        services.syncthing = {
          enable = true;
          user = cfg.user;
          dataDir = cfg.dataDir;
          configDir = cfg.configDir;
          guiAddress = "${cfg.guiAddress}:${cfg.guiPort}";
          openDefaultPorts = true;
        };
        boot.kernel.sysctl = {
          "fs.inotify.max_user_watches" = lib.mkForce 1048576;
        };
      }
      (
        lib.mkIf (cfg.guiAddress == "0.0.0.0")
        {
          networking.firewall.allowedTCPPorts = lib.mkDefault ["${cfg.guiPort}"];
        }
      )
    ];
  };
}
