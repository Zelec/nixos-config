{
  flake.nixosModules.renovate = {
    config,
    pkgs,
    lib,
    ...
  }: let
    sopsSetup = {
      sopsFile = ./secrets.yml;
      owner = config.systemd.services.renovate.serviceConfig.User;
      group = config.systemd.services.renovate.serviceConfig.Group;
      restartUnits = ["renovate.service"];
    };
    cfg = config.preferences.renovate;
  in {
    options.preferences.renovate = {
      runtimePackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = with pkgs; [
          bash
          coreutils
          curl
          gawk
          git
          gnused
          jq
          nix
          nodejs
          openssh
          wget
        ];
      };
    };
    config = {
      users.users.renovate = {
        isSystemUser = true;
        group = "renovate";
        home  = "/var/lib/renovate";
      };
      users.groups.renovate = {};
      systemd.services.renovate = {
        serviceConfig = {
          User = "renovate";
          Group = "renovate";
          DynamicUser = lib.mkForce false; # fix
        };
      };
      systemd.tmpfiles.rules = [ 
        "d /var/lib/renovate/.ssh 0700 renovate renovate - -"
      ];
      sops.secrets."renovate/token" = sopsSetup;
      sops.secrets."renovate/github_com_token" = sopsSetup;
      sops.secrets."renovate/deploy_private_ssh_key" = sopsSetup // {
        path = "/var/lib/renovate/.ssh/id_ed25519";
        mode = "0600";
      };
      sops.secrets."renovate/deploy_known_hosts" = sopsSetup // {
        path = "/var/lib/renovate/.ssh/known_hosts";
        mode = "0600";
      };
      home-manager.users.renovate = {
        home.stateVersion = "24.11";
        programs.ssh = {
          matchBlocks = {
            "*" = {
              hostname = "*";
              user = "git";
              identityFile = "/var/lib/renovate/.ssh/id_ed25519";
            };
          };
        };
      };
      services.renovate = {
        enable = true;
        runtimePackages = cfg.runtimePackages;
        validateSettings = true;
        # Every 10 mins
        schedule = "*:0/10";
        settings = {
          autodiscover = true;
          endpoint = "https://git.tgdev.net";
          gitAuthor = "Renovate <renovate@timeguard.ca>";
          lockFileMaintenance.enabled = true;
          nix.enabled = true;
          onboardingConfig = {
            "$schema" = "https://docs.renovatebot.com/renovate-schema.json";
            extends = [
              "local>Renovate-Bot/renovate-config"
            ];
          };
          platform = "forgejo";
          rebaseWhen = "behind-base-branch";
          timezone = config.preferences.timeZone;
        };
        environment = {
          # LOG_LEVEL = "debug";
        };
        credentials = {
          RENOVATE_TOKEN = config.sops.secrets."renovate/token".path;
          RENOVATE_GITHUB_COM_TOKEN = config.sops.secrets."renovate/github_com_token".path;
        };
      };
    };
  };
}
