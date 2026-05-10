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
      sysctlVmSwappiness = lib.mkOption {
        type = lib.types.ints.positive;
        default = 5;
      };
    };
    config = {
      boot.kernel.sysctl = {
        "vm.swappiness" = cfg.sysctlVmSwappiness;
      };
    };
  };
}
