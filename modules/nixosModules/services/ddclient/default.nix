{
  flake.nixosModules.ddclient = {
    config,
    lib,
    ...
  }: let
    cfg = config.preferences.ddclient;
  in {
    options.preferences.ddclient = {
      configOptions = lib.mkOption {
        default = "";
        type = lib.types.lines;
      };
    };
    config = {
      users.groups.ddclient-secrets = {};
      systemd.services.ddclient = {
        serviceConfig = {
          SupplementaryGroups = lib.mkOptionDefault ["ddclient-secrets"];
          ReadOnlyPaths = lib.mkOptionDefault ["/run/secrets"];
        };
      };
      sops.secrets.ddclient_cloudflare_token = {
        sopsFile = ./secrets.yml;
        group = "ddclient-secrets";
        restartUnits = ["ddclient.service"];
        mode = "0440";
      };
      services.ddclient = {
        enable = true;
        usev4 = "webv4, web=ipinfo.io/ip";
        usev6 = "disabled";
        protocol = "cloudflare";
        ssl = true;
        username = "token";
        passwordFile = config.sops.secrets.ddclient_cloudflare_token.path;
        extraConfig = cfg.configOptions;
      };
    };
  };
}
