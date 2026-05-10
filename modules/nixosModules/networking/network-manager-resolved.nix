{
  flake.nixosModules.network-manager-resolved = {...}: {
    networking = {
      networkmanager = {
        enable = true;
        dns = "systemd-resolved";
      };
    };
    services = {
      resolved = {
        enable = true;
        fallbackDns = ["1.1.1.1" "1.0.0.1"];
      };
    };
  };
}
