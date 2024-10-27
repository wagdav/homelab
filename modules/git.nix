{ config, lib, pkgs, ... }:
let
  httpPort = 8022;

in
{
  imports = [
    ./consul-catalog.nix
    ./nas.nix
  ];

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

    borgbackup.jobs.git = {
      paths = "/srv/git";
      repo = "/mnt/nas/backup/borg/git";
      encryption.mode = "none";
      doInit = false;
      user = "borg";
      group = "git";
      startAt = "daily";
      prune.keep = {
        within = "1d";
        daily = 7;
        weekly = 4;
        monthly = 12;
        yearly = 10;
      };
    };
  };

  users.users.borg = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "git" ];
  };

  networking.firewall.allowedTCPPorts = [ httpPort ];
}
