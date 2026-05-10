{
  flake.nixosModules.adb = {config, ...}: {
    programs.adb.enable = true;
    users.users.${config.preferences.user.name}.extraGroups = ["adbusers"];
  };
}
