{ config, lib, ... }:

{
  imports = [
    ./nas.nix
  ];

  users.users.borg = {
    isNormalUser = lib.mkForce true;
    isSystemUser = lib.mkForce false;
    uid = 1000;
    extraGroups = [ "git" ];
  };
  users.groups.borg = {
    gid = 1000;
  };

  systemd.services.borgbackup-repo-git.serviceConfig = {
    User = "borg";
  };
  systemd.services.borgbackup-repo-x1.serviceConfig = {
    User = "borg";
  };

  services.borgbackup.repos = {
    git = {
      authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBpy7MNdMJUmrhlKaZEfm4GsoZWDZQUSTuUrRRlKCqRT root@git" ];
      path = "/mnt/nas/backup/borg/git";
    };
    x1 = {
      authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDYh9g6mgiD2ckSeeZ+eXhEYSnFPo1/jNKpmhTX5U5i3 root@x1" ];
      path = "/mnt/nas/backup/borg/x1";
    };
  };
}
