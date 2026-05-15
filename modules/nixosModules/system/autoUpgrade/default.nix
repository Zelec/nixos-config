{
  flake.nixosModules.autoUpgrade = {
    config,
    lib,
    pkgs,
    ...
  }: let
    sopsSetup = {
      owner = "root";
      group = "root";
      mode = "0600";
      sopsFile = ./secrets.yml;
    };
    cfg = config.preferences.autoUpgrade;
  in {
    options.preferences.autoUpgrade = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      dates = lib.mkOption {
        type = lib.types.str;
        default = "01:00";
      };
      randomizedDelaySec = lib.mkOption {
        type = lib.types.str;
        default = "30min";
      };
      allowReboot = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      rebootWindow = {
        lower = lib.mkOption {
          type = lib.types.str;
          default = "01:00";
        };
        upper = lib.mkOption {
          type = lib.types.str;
          default = "03:00";
        };
      };
    };
    config = {
      sops.secrets."autoUpgrade/ssh-key-private" = sopsSetup;
      sops.secrets."autoUpgrade/ssh-key-public" = sopsSetup;
      system.autoUpgrade = {
        enable = cfg.enable;
        dates = cfg.dates;
        randomizedDelaySec = cfg.randomizedDelaySec;
        allowReboot = cfg.allowReboot;
        rebootWindow = {
          lower = cfg.rebootWindow.lower;
          upper = cfg.rebootWindow.upper;
        };
        flags = [
          "--refresh"
        ];
        flake = "git+ssh://git@ssh-git.tgdev.net:2222/Zelec/nixos-config.git?ref=main";
      };
      systemd.services.nixos-upgrade.serviceConfig = {
        Environment = "GIT_SSH_COMMAND=${pkgs.openssh}/bin/ssh -i ${config.sops.secrets."autoUpgrade/ssh-key-private".path} -o StrictHostKeyChecking=accept-new";
      };
    };
  };
}
