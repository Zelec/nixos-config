#
# https://casualcompute.com/posts/creating-a-basic-router-using-nixos/
#
{
  flake.nixosModules.hostNixOS-Router = {...}: let
    # E0/LAN
    e0 = "enp2s0";
    lan = "br0";
    # E1/WAN
    e1 = "enp3s0";
    wan = e1;
    # E2/DMZ
    e2 = "enp4s0";
    dmz = e2;
    # E3/HA
    e3 = "enp5s0";
    ha = e3;
    # Unassigned ports
    e4 = "enp6s0";
    e5 = "enp7s0";
    e6 = "enp8s0f0";
    e7 = "enp8s0f1";
    e8 = "enp9s0f0";
    e9 = "enp9s0f1";
  in {
    boot.kernel.sysctl = {
      "net.ipv4.conf.all.forwarding" = true;
      # "net.ipv6.conf.all.forwarding" = true;
    };
    networking = {
      # Disable firewall (this will be handled by nftables)
      firewall.enable = false;
      bridges = {
        "${lan}" = {
          interfaces = [
            e0
            e4
            e5
            e6
            e7
            e8
            e9
          ];
        };
      };
      interfaces = {
        "${wan}" = {
          # DHCP needed to acquire IP for WAN
          useDHCP = true;
        };
        "${lan}" = {
          # Static IP needed for LAN gateway
          useDHCP = false;
          ipv4.addresses = [
            {
              address = "10.15.70.1";
              prefixLength = 24;
            }
          ];
        };
      };
      nftables = {
        enable = true;
        tables = {
          # Allow select IPv4 traffic
          filterV4 = {
            family = "ip";
            content = ''
              chain input {
                type filter hook input priority 0; policy drop;
                iifname "lo" accept comment "allow loopback traffic"
                iifname "${wan}" accept comment "allow traffic from LAN"
                iifname "${lan}" ct state established, related accept comment "allow established traffic from WAN"
                iifname "${lan}" ip protocol icmp counter accept comment "allow ICMP traffic from WAN"
                iifname "${lan}" tcp dport 22 counter accept comment "allow SSH traffic from WAN"
                iifname "${lan}" counter drop comment "drop all other traffic from WAN"
              }
              chain forward {
                type filter hook forward priority 0; policy drop;
                iifname "${wan}" oifname "${lan}" accept comment "allow LAN connections to forward to WAN"
                iifname "${lan}" oifname "${wan}" ct state established, related accept comment "allow established WAN connections to forward to LAN"
              }
            '';
          };
          # Allow forwarded traffic out through WAN, masquerades IP
          natV4 = {
            family = "ip";
            content = ''
              chain postrouting {
                type nat hook postrouting priority 100; policy accept;
                oifname "${lan}" masquerade comment "replace source address with WAN IP address"
              }
            '';
          };
          # Drops all IPv6 traffic
          filterV6 = {
            family = "ip6";
            content = ''
              chain input {
                type filter hook input priority 0; policy drop;
              }
              chain forward {
                type filter hook forward priority 0; policy drop;
              }
            '';
          };
        };
      };
    };
  };
}
