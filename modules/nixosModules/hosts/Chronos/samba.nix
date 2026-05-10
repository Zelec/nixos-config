{
  flake.nixosModules.hostChronos = {config, ...}: {
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
