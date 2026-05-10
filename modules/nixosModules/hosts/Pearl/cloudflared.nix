{self, ...}: {
  flake.nixosModules.hostPearl = {config, ...}: let
    sopsConfig = {
      sopsFile = ./secrets.yml;
    };
  in {
    imports = with self.nixosModules; [
      cloudflared
    ];
    sops.secrets."cloudflared_tunnel_tokens/45a728f2-9d83-4e19-b73d-f6098cf63458" =
      sopsConfig
      // {
        restartUnits = ["cloudflared-tunnel-45a728f2-9d83-4e19-b73d-f6098cf63458.service"];
      };
    preferences.cloudflared.tunnels = {
      "45a728f2-9d83-4e19-b73d-f6098cf63458" = {
        credentialsFile = config.sops.secrets."cloudflared_tunnel_tokens/45a728f2-9d83-4e19-b73d-f6098cf63458".path;
        ingress = {
          "cinny.timeguard.ca" = null;
          "element.timeguard.ca" = null;
          "git.tgdev.ca" = null;
          "git.tgdev.net" = null;
          "hookshot.timeguard.ca" = null;
          "jellyfin.timeguard.ca" = null;
          "matrix.timeguard.ca" = null;
          "vault.timeguard.ca" = null;
        };
      };
    };
  };
}
