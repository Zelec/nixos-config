{inputs, ...}: {
  flake.nixosModules.hostAmethyst = let
    # Private flake inputs
    privateConfig = inputs.private.values.hosts.Amethyst;
  in {
    services.resolved = {
      enable = true;
      dnsovertls = "opportunistic";
    };
    networking = privateConfig.networking;
  };
}
