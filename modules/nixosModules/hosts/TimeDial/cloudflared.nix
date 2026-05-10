{self, ...}: {
  flake.nixosModules.hostTimeDial = {config, ...}: let
    sopsConfig = {
      sopsFile = ./secrets.yml;
    };
  in {
    imports = with self.nixosModules; [
      cloudflared
    ];
    sops.secrets."cloudflared_tunnel_tokens/4c38ad3b-441e-483f-894c-07a0246a6449" =
      sopsConfig
      // {
        restartUnits = ["cloudflared-tunnel-4c38ad3b-441e-483f-894c-07a0246a6449.service"];
      };
    preferences.cloudflared.tunnels = {
      "4c38ad3b-441e-483f-894c-07a0246a6449" = {
        credentialsFile = config.sops.secrets."cloudflared_tunnel_tokens/4c38ad3b-441e-483f-894c-07a0246a6449".path;
        ingress = {
          # "restic.timeguard.ca" = null;
        };
      };
    };
  };
}
