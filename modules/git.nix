{ config, pkgs, ... }:
let
  httpPort = 8022;

in
{
  imports = [ ./consul-catalog.nix ];

  users.users.git = {
    isNormalUser = true;
    shell = "${pkgs.git}/bin/git-shell";
    openssh.authorizedKeys.keys = (import ./keys.nix).dwagner;
  };

  services = {
    cgit.git = {
      enable = true;
      scanPath = "/srv/git";
      settings = {
        enable-git-config = true;
        clone-url = "git@nuc:/srv/git/$CGIT_REPO_URL";
        source-filter = "${pkgs.cgit}/lib/cgit/filters/syntax-highlighting.py";
      };
    };

    nginx.virtualHosts.git.listen = [
      {
        addr = "0.0.0.0";
        port = httpPort;
      }
      {
        addr = "[::]";
        port = httpPort;
      }
    ];

    consul.catalog = [
      {
        name = "cgit";
        port = httpPort;
        tags = (import ./lib/traefik.nix).tagsForHost "git";
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [ httpPort ];
}
