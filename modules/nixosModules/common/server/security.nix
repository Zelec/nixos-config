{
  flake.nixosModules.hostServerCommon = {
    config,
    lib,
    ...
  }: {
    networking.firewall = lib.mkMerge [
      {
        enable = true;
        allowedTCPPorts = [
          # SSH
          22
          #WebServer
          80
          443
        ];
      }
      (
        lib.mkIf (config.services.tailscale.enable) {
          checkReversePath = "loose";
        }
      )
    ];
    services = {
      fail2ban = {
        enable = true;
        maxretry = 5;
        ignoreIP = [
          # Regular IPs
          "10.0.0.0/8"
          "172.16.0.0/12"
          "192.168.0.0/16"
          # Tailscale subnet
          "100.64.0.0/10"
        ];
        bantime = "1h";
        bantime-increment = {
          enable = true;
          multipliers = "1 2 4 8 16 32 64 128 256";
          maxtime = "168h";
          overalljails = true;
        };
      };
    };
  };
}
