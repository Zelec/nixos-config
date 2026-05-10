{
  flake.nixosModules.hostTimeDial = {config, ...}: let
    # Taken from IronicBadger's repo because why repeat the same lines over and over?
    # https://github.com/ironicbadger/nix-config/blob/28b866b9c203277176db87d0c933855bdb8a52d9/hosts/nixos/morphnix/default.nix#L250-L259
    mkShare = path: {
      "path" = "${path}";
      "browseable" = "yes";
      "read only" = "no";
      "guest ok" = "no";
      "create mask" = "0644";
      "directory mask" = "0755";
      "force user" = "${config.preferences.user.name}";
      "force group" = "users";
    };
  in {
    services.samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = config.networking.hostName;
          "netbios name" = config.networking.hostName;
          "security" = "user";
          #"use sendfile" = "yes";
          #"max protocol" = "smb2";
          # note: localhost is the ipv6 localhost ::1
          # 100.64.0.0/10 is the range tailscale uses
          "hosts allow" = "192.168.0.0/16 172.16.0.0/12 10.0.0.0/8 100.64.0.0/10 127.0.0.1 localhost";
          "hosts deny" = "0.0.0.0/0";
          "guest account" = "nobody";
          "map to guest" = "bad user";
        };
        "homes" = {
          "comment" = "Home Directories";
          "browseable" = "yes";
          "valid users" = "%S";
          "writable" = "yes";
        };
        "media" = mkShare "/media/Storage_01/media";
      };
    };

    services.samba-wsdd = {
      enable = true;
      openFirewall = true;
    };

    services.avahi = {
      publish.enable = true;
      publish.userServices = true;
      # ^^ Needed to allow samba to automatically register mDNS records (without the need for an `extraServiceFile`
      nssmdns4 = true;
      # ^^ Not one hundred percent sure if this is needed- if it aint broke, don't fix it
      enable = true;
      openFirewall = true;
    };

    networking.firewall.allowPing = true;
  };
}
