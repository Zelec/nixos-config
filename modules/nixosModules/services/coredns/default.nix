{inputs, ...}: {
  flake.nixosModules.coredns = {lib, ...}: let
    # Private flake inputs
    privateConfig = inputs.private.values.coredns;
    zoneFiles = privateConfig.zoneFiles;
    ipsCommon = privateConfig.ipsCommon;
    ipsTailscale = privateConfig.ipsTailscale;
    ipsMainNet = privateConfig.ipsMainNet;
    dnsRewrites = privateConfig.dnsRewrites;
  in {
    services.coredns = {
      enable = true;
      config = ''
        (tg_default) {
          log
          errors
          bufsize 1232
          # prometheus :9153
          cache 30
          acl {
            filter type AAAA
          }

          forward internal.timeguard.ca. dns://10.23.23.1
          file ${zoneFiles}/in-addr.arpa/10.23.23.zone 23.23.10.in-addr.arpa
          file ${zoneFiles}/timeguard.ca/infra.zone infra.timeguard.ca
        }
        (tg_internal_redirects) {
          ${dnsRewrites}
        }
        (tg_static_hosts_mainnet) {
          hosts {
            ${ipsCommon}
            ${ipsMainNet}
            # Needed, otherwise hosts will stop execution if nothing matches
            fallthrough
          }
        }
        (tg_static_hosts_tailscale) {
          hosts {
            ${ipsCommon}
            ${ipsTailscale}
            # Needed, otherwise hosts will stop execution if nothing matches
            fallthrough
          }
        }
        (cloudflare_default_dns_route) {
          forward . tls://1.1.1.1 tls://1.0.0.1 {
            tls_servername cloudflare-dns.com
            health_check 5s
          }
        }
        # Tailscale
        . {
          view tailscale {
            expr incidr(client_ip(), '100.64.0.0/10')
          }
          import tg_default
          import tg_static_hosts_tailscale
          import tg_internal_redirects
          import cloudflare_default_dns_route
        }
        # Default route
        . {
          import tg_default
          import tg_static_hosts_mainnet
          import tg_internal_redirects
          import cloudflare_default_dns_route
        }
      '';
    };
  };
}
