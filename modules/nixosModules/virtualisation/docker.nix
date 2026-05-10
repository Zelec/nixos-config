{self, ...}: {
  flake.nixosModules.docker = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.preferences.docker;
  in {
    imports = with self.nixosModules; [
      # Default containers for all
      containers-caddy
      containers-watchtower
    ];
    options.preferences.docker = {
      storageDriver = lib.mkOption {
        type = lib.types.str;
        default = "btrfs";
      };
      nvidia.enable = lib.mkEnableOption "Enables NVIDIA in Docker";
    };
    config = lib.mkMerge [
      {
        virtualisation = {
          containers.enable = true;
          oci-containers.backend = "docker";
          docker = {
            enable = true;
            autoPrune = {
              enable = true;
              dates = "weekly";
            };
            liveRestore = false;
            storageDriver = cfg.storageDriver;
          };
        };
      }
      (lib.mkIf (cfg.nvidia.enable) {
        environment.systemPackages = with pkgs; [
          nvidia-container-toolkit
        ];
        hardware.nvidia-container-toolkit = {
          enable = true;
          mount-nvidia-executables = true;
          mount-nvidia-docker-1-directories = true;
          device-name-strategy = "index";
        };
        virtualisation = {
          docker = {
            daemon.settings = {
              features.cdi = true;
              # default-runtime =  "nvidia";
              # runtimes.nvidia.path =  "${pkgs.nvidia-container-toolkit}/bin/nvidia-container-runtime";
              # exec-opts = ["native.cgroupdriver=cgroupfs"];
            };
          };
        };
      })
    ];
  };
}
