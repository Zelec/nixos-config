{ config, pkgs, ... }:

{
  home.stateVersion = "23.11";

  home.username = "zelec";
  home.homeDirectory = "/home/zelec";

  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  home.sessionVariables = {
    EDITOR = "nano";
  };
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = [
        "qemu:///system"
        "qemu+ssh://TimeDial.timeguard.ca/system"
      ];
    };
    "org/virt-manager/virt-manager" = {
      "system-tray" = true;
      "xmleditor-enabled" = true;
    };
    "org/virt-manager/virt-manager/console" = {
      "resize-guest" = 1;
    };
  };
  programs = {
    bash = {
      enable = true;
      shellAliases = {
        oxker = "docker pull docker.io/mrjackwills/oxker:latest && docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock:ro docker.io/mrjackwills/oxker:latest";
        ctop = "docker pull quay.io/vektorlab/ctop:latest && docker run --name ctop -it --rm -v /var/run/docker.sock:/var/run/docker.sock quay.io/vektorlab/ctop:latest";
      };
      sessionVariables = {
        EDITOR = "nano";
        DOCKER_BUILDKIT = "1";
        COMPOSE_DOCKER_CLI_BUILD = "1";
      };
      bashrcExtra = ''
        PS1="\[\e[96m\][\u@\h\[\e[0m\] \[\e[97m\]\W\[\e[96m\]]\\$\[\e[97m\]\[\e[0m\] "
        # Gitignore creator
        gi() {
          curl -sL "https://www.gitignore.io/api/$@"
        }

        # Container upgrade via watchtower
        watchtower() {
          if [ ! -f "$HOME/.docker/config.json" ]; then
            mkdir -p "$HOME/.docker"
            touch "$HOME/.docker/config.json"
            echo "{}" >> "$HOME/.docker/config.json"
          fi
          docker pull docker.io/containrrr/watchtower:latest
          docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v "$HOME/.docker/config.json":/config.json:ro docker.io/containrrr/watchtower:latest --run-once
        }
      '';
    };
    home-manager.enable = true;
    git = {
      enable = true;
      userName  = "Isaac Towns";
      userEmail = "Isaac@timeguard.ca";
      lfs.enable = true;
      extraConfig = {
        init = {
          defaultBranch = "main";
        };
      };
    };
  };
}
