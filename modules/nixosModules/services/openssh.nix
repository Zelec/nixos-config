{
  flake.nixosModules.openssh = {...}: {
    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.PermitRootLogin = "prohibit-password";
    };
  };
}
