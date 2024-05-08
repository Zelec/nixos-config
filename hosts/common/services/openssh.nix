{ lib, inputs, ... }:
{
  services.openssh = {
    enable = lib.mkDefault true;
    settings.PasswordAuthentication = lib.mkDefault false;
    settings.PermitRootLogin = lib.mkDefault "prohibit-password";
  };
}