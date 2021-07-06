{ config, ... }:
let
  user = "git";
  group = "gitolite";
  httpPort = 8022;

in
{
  imports = [ ./consul-catalog.nix ];

  services = {
    gitolite = {
      enable = true;
      adminPubkey = (import ./keys.nix).dwagner;

      inherit user group;
    };

    gitweb = {
      projectroot = "${config.services.gitolite.dataDir}/repositories";
    };

    nginx = {
      enable = true;

      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;

      virtualHosts."_".listen = [
        {
          addr = "0.0.0.0";
          port = httpPort;
        }
        {
          addr = "[::]";
          port = httpPort;
        }
      ];

      gitweb = {
        enable = true;
        inherit group;
        location = "";
      };
    };

    consul.catalog = [
      {
        name = "gitweb";
        port = httpPort;
        tags = (import ./lib/traefik.nix).tagsForHost "git";
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [ httpPort ];
}
