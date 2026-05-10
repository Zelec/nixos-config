{self, ...}: {
  flake.nixosModules.sway = {
    config,
    pkgs,
    lib,
    ...
  }: {
    imports = [
      self.nixosModules.pipewire
    ];
    environment.systemPackages = with pkgs; [
      grim
      light
      mako
      pulseaudio
      slurp
      waylock
      wl-clipboard
    ];
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
    fonts.packages = with pkgs;
      [
        font-awesome
      ]
      ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
    services.gnome.gnome-keyring.enable = true;
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };
    services.displayManager = {
      defaultSession = "sway";
      sddm.enable = true;
      sddm.wayland.enable = true;
      autoLogin.enable = true;
      autoLogin.user = config.preferences.user.name;
    };
    xdg.portal = {
      enable = true;
      # Use the wlr portal for wlroots-specific features and GTK as a fallback
      extraPortals = [
        pkgs.xdg-desktop-portal-wlr
        pkgs.xdg-desktop-portal-gtk
      ];
      # Use GTK as the common default since wlr is not as featureful outside of screen capture
      config.common.default = ["gtk"];
      # Explicitly use wlr for screen capture interfaces
      config.sway = {
        "org.freedesktop.impl.portal.Screenshot" = ["wlr"];
        "org.freedesktop.impl.portal.ScreenCast" = ["wlr"];
      };
    };
    home-manager.users.${config.preferences.user.name} = {
      programs.swaylock = {
        enable = true;
      };
      services.swayidle = {
        enable = true;
        events = [
          {
            event = "before-sleep";
            command = "${pkgs.swaylock}/bin/swaylock -f";
          }
          {
            event = "lock";
            command = "${pkgs.swaylock}/bin/swaylock -f";
          }
        ];
        timeouts = [
          {
            timeout = 360;
            command = "${pkgs.swaylock}/bin/swaylock -f";
          }
        ];
      };
      programs.waybar = {
        enable = true;
        # https://github.com/cjbassi/config/tree/master/.config/waybar
        # https://github.com/cjbassi/config/tree/ac1428769aa85becc962bfb9bfcfe879cad5f9f6/.config/waybar
        # https://json-to-nix.pages.dev/
        settings = {
          mainBar = {
            layer = "top";
            position = "bottom";
            modules-left = [
              "sway/workspaces"
              "custom/right-arrow-dark"
            ];
            modules-center = [
              "custom/left-arrow-dark"
              "clock#1"
              "custom/left-arrow-light"
              "custom/left-arrow-dark"
              "clock#2"
              "custom/right-arrow-dark"
              "custom/right-arrow-light"
              "clock#3"
              "custom/right-arrow-dark"
            ];
            modules-right = [
              "custom/left-arrow-dark"
              "pulseaudio"
              "custom/left-arrow-light"
              "custom/left-arrow-dark"
              "memory"
              "custom/left-arrow-light"
              "custom/left-arrow-dark"
              "cpu"
              "custom/left-arrow-light"
              "custom/left-arrow-dark"
              "battery"
              "custom/left-arrow-light"
              "custom/left-arrow-dark"
              "disk"
              "custom/left-arrow-light"
              "custom/left-arrow-dark"
              "tray"
            ];
            "custom/left-arrow-dark" = {
              format = "";
              tooltip = false;
            };
            "custom/left-arrow-light" = {
              format = "";
              tooltip = false;
            };
            "custom/right-arrow-dark" = {
              format = "";
              tooltip = false;
            };
            "custom/right-arrow-light" = {
              format = "";
              tooltip = false;
            };
            "sway/workspaces" = {
              disable-scroll = true;
              format = "{name}";
            };
            "clock#1" = {
              format = "{:%a}";
              tooltip = false;
            };
            "clock#2" = {
              format = "{:%H:%M}";
              tooltip = false;
            };
            "clock#3" = {
              format = "{:%m-%d}";
              tooltip = false;
            };
            pulseaudio = {
              format = "{icon} {volume:2}%";
              format-bluetooth = "{icon}  {volume}%";
              format-muted = "MUTE";
              format-icons = {
                headphones = "";
                default = [
                  ""
                  ""
                ];
              };
              scroll-step = 5;
              on-click = "pamixer -t";
              on-click-right = "pavucontrol";
            };
            memory = {
              interval = 5;
              format = "Mem {}%";
            };
            cpu = {
              interval = 5;
              format = "CPU {usage:2}%";
            };
            battery = {
              states = {
                good = 95;
                warning = 30;
                critical = 15;
              };
              format = "{icon} {capacity}%";
              format-icons = [
                ""
                ""
                ""
                ""
                ""
              ];
            };
            disk = {
              interval = 5;
              format = "Disk {percentage_used:2}%";
              path = "/";
            };
            tray = {
              icon-size = 20;
            };
          };
        };
        style = ''
          * {
            font-size: 20px;
            font-family: monospace;
          }

          window#waybar {
            background: #292b2e;
            color: #fdf6e3;
          }

          #custom-right-arrow-dark,
          #custom-left-arrow-dark {
            color: #1a1a1a;
          }
          #custom-right-arrow-light,
          #custom-left-arrow-light {
            color: #292b2e;
            background: #1a1a1a;
          }

          #workspaces,
          #clock.1,
          #clock.2,
          #clock.3,
          #pulseaudio,
          #memory,
          #cpu,
          #battery,
          #disk,
          #tray {
            background: #1a1a1a;
          }

          #workspaces button {
            padding: 0 2px;
            color: #fdf6e3;
          }
          #workspaces button.focused {
            color: #268bd2;
          }
          #workspaces button:hover {
            box-shadow: inherit;
            text-shadow: inherit;
          }
          #workspaces button:hover {
            background: #1a1a1a;
            border: #1a1a1a;
            padding: 0 3px;
          }

          #pulseaudio {
            color: #268bd2;
          }
          #memory {
            color: #2aa198;
          }
          #cpu {
            color: #6c71c4;
          }
          #battery {
            color: #859900;
          }
          #disk {
            color: #b58900;
          }

          #clock,
          #pulseaudio,
          #memory,
          #cpu,
          #battery,
          #disk {
            padding: 0 10px;
          }
        '';
      };
      wayland.windowManager.sway = {
        enable = true;
        xwayland = true;
        config = {
          modifier = "Mod4";
          # Use kitty as default terminal
          #terminal = "kitty";
          startup = [
            # Launch Firefox on start
            # {command = "firefox";}
          ];
          bars = [
            {
              command = "${pkgs.waybar}/bin/waybar";
            }
          ];
          keybindings = lib.mkOptionDefault {
            # Brightness
            "XF86MonBrightnessDown" = ''exec ${pkgs.light}/bin/light -U 10'';
            "XF86MonBrightnessUp" = ''exec ${pkgs.light}/bin/light -A 10'';

            # Volume
            "XF86AudioRaiseVolume" = ''exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +1%'';
            "XF86AudioLowerVolume" = ''exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -1%'';
            "XF86AudioMute" = ''exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle'';
          };
        };
      };
    };
  };
}
