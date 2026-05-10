{
  flake.nixosModules.chromium = {config, pkgs, ...}: {
    config = {
      home-manager.users.${config.preferences.user.name} = {
        programs.chromium = {
          enable = true;
          package = pkgs.chromium;
        };
      };
    };
  };
}
