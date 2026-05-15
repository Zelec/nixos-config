# System tweaks/tunables
{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.base = {
    config,
    lib,
    ...
  }: let
    cfg = config.preferences.tunables;
  in {
    options.preferences.tunables = {
      sysctl = {
        vm-swappiness = lib.mkOption {
          type = lib.types.ints.positive;
          default = 60;
        };
      };
      systemd = {
        oomd-enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
      };
    };
    config = {
      boot.kernel.sysctl = {
        "vm.swappiness" = cfg.sysctl.vm-swappiness;
      };
      systemd.oomd = {
        enable = cfg.systemd.oomd-enable;
        enableRootSlice = true;
        enableSystemSlice = true;
        enableUserSlices = true;
        settings.OOM = {
          DefaultMemoryPressureDurationSec = "20s";
        };
      };
      systemd.slices."user".sliceConfig = {
        ManagedOOMMemoryPressureLimit = "90%";
      };
    };
  };
}
