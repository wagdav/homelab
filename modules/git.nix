{ config, lib, pkgs, ... }:
let
  httpPort = 80;

in
{
  users.users.git = {
    isSystemUser = true;
    group = "git";
    shell = "${pkgs.git}/bin/git-shell";
    openssh.authorizedKeys.keys = (import ./keys.nix).dwagner;
  };
  users.groups.git = { };

  services = {
    cgit.git = {
      enable = true;
      user = "cgit";
      group = "git";
      scanPath = "/srv/git";
      settings = {
        enable-git-config = true;
        clone-url = "git@git:/srv/git/$CGIT_REPO_URL";
        source-filter = "${pkgs.cgit}/lib/cgit/filters/syntax-highlighting.py";
        about-filter = "${pkgs.cgit}/lib/cgit/filters/about-formatting.sh";
        readme = ":README.md";
        root-title = "Homelab git repositories";
        root-desc = "Git repositories hosted at home";
        section-from-path = 1;
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

    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.PermitRootLogin = "no";
    };

  };

  networking.firewall.allowedTCPPorts = [ httpPort ];
}
