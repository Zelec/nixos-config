{
  flake.nixosModules.forgejo-runner = {
    config,
    pkgs,
    lib,
    ...
  }: let
    cfg = config.preferences.forgejo-runner;
  in {
    options.preferences.forgejo-runner = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "${config.networking.hostName}";
      };
      url = lib.mkOption {
        type = lib.types.str;
        default = "https://git.tgdev.net";
      };
      cacheHost = lib.mkOption {
        type = lib.types.str;
        default = "";
      };
      runnerImageRoot = lib.mkOption {
        type = lib.types.str;
        default = "docker.tgdev.ca/public/mirror/catthehacker/ubuntu";
      };
      enableGenericLabels = lib.mkOption {
        default = true;
        example = false;
        type = lib.types.bool;
      };
      enableGenericHostLabels = lib.mkOption {
        default = false;
        example = false;
        type = lib.types.bool;
      };
      enableSpesificHostLabels = lib.mkOption {
        default = true;
        example = false;
        type = lib.types.bool;
      };
      enablePrivilegedLabels = lib.mkOption {
        default = true;
        example = false;
        type = lib.types.bool;
      };
      containerOptions = lib.mkOption {
        type = lib.types.str;
        default = "";
      };
      hostPackages = lib.mkOption {
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
          ssh-agents
          wget
        ];
      };
    };
    config = {
      users.users.gitea-runner = {
        isSystemUser = true;
        group = "gitea-runner";
      };
      users.groups.gitea-runner = {};
      systemd.services.gitea-runner-default = {
        serviceConfig = {
          User = "gitea-runner";
          Group = "gitea-runner";
          DynamicUser = lib.mkForce false; # fix
        };
      };
      sops.secrets.forgejo_runner_token = {
        sopsFile = ./secrets.yml;
        owner = config.systemd.services.gitea-runner-default.serviceConfig.User;
        group = config.systemd.services.gitea-runner-default.serviceConfig.Group;
        restartUnits = [
          "gitea-runner-generic-docker.service"
          "gitea-runner-generic-host.service"
          "gitea-runner-spesific-host.service"
          "gitea-runner-privileged-docker.service"
        ];
      };
      services.gitea-actions-runner = {
        package = pkgs.forgejo-runner;
        instances = {
          generic-docker = {
            enable = cfg.enableGenericLabels;
            name = "${cfg.name}-generic-docker";
            url = cfg.url;
            tokenFile = config.sops.secrets.forgejo_runner_token.path;
            labels = [
              "ubuntu-latest:docker://${cfg.runnerImageRoot}:act-latest"
              "ubuntu-22.04:docker://${cfg.runnerImageRoot}:act-22.04"
              "ubuntu-20.04:docker://${cfg.runnerImageRoot}:act-20.04"
              "ubuntu-18.04:docker://${cfg.runnerImageRoot}:act-18.04"
              "nix-container:docker://docker.tgdev.ca/public/nix-runner:latest"
            ];
            hostPackages = cfg.hostPackages;
            settings = {
              cache = {
                enabled = true;
                host = cfg.cacheHost;
              };
              container = {
                force_pull = true;
                privileged = false;
                options = cfg.containerOptions;
              };
              runner.capacity = 1;
            };
          };
          generic-host = {
            enable = cfg.enableGenericHostLabels;
            name = "${cfg.name}-generic-host";
            url = cfg.url;
            tokenFile = config.sops.secrets.forgejo_runner_token.path;
            labels = [
              "nix-native:host"
            ];
            hostPackages = cfg.hostPackages;
            settings = {
              cache = {
                enabled = true;
                host = cfg.cacheHost;
              };
              container = {
                force_pull = true;
                privileged = false;
                options = cfg.containerOptions;
              };
              runner.capacity = 1;
            };
          };
          spesific-host = {
            enable = cfg.enableSpesificHostLabels;
            name = "${cfg.name}-spesific-host";
            url = cfg.url;
            tokenFile = config.sops.secrets.forgejo_runner_token.path;
            labels = [
              "${cfg.name}-native:host"
              "${cfg.name}-nix-container:docker://docker.tgdev.ca/public/nix-runner:latest"
              "${cfg.name}-ubuntu-latest:docker://${cfg.runnerImageRoot}:act-latest"
            ];
            hostPackages = cfg.hostPackages;
            settings = {
              cache = {
                enabled = true;
                host = cfg.cacheHost;
              };
              container = {
                force_pull = true;
                privileged = false;
                options = cfg.containerOptions;
              };
              runner.capacity = 1;
            };
          };
          privileged-docker = {
            enable = cfg.enablePrivilegedLabels;
            name = "${cfg.name}-privileged-docker";
            url = cfg.url;
            tokenFile = config.sops.secrets.forgejo_runner_token.path;
            labels = [
              "${cfg.name}-native:host"
              "${cfg.name}-nix-container:docker://docker.tgdev.ca/public/nix-runner:latest"
              "${cfg.name}-ubuntu-latest:docker://${cfg.runnerImageRoot}:act-latest"
            ];
            hostPackages = cfg.hostPackages;
            settings = {
              cache = {
                enabled = true;
                host = cfg.cacheHost;
              };
              container = {
                force_pull = true;
                privileged = true;
                options = cfg.containerOptions;
              };
              runner.capacity = 1;
            };
          };
        };
      };
    };
  };
}
