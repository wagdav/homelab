{ config, lib, pkgs, ... }:

{
  documentation.enable = false;

  nix.gc = {
    automatic = true;
    options = ''--delete-older-than 30d'';
  };

  i18n.defaultLocale = "en_US.UTF-8";

  time.timeZone = "Europe/Zurich";

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  services = {
    openssh = {
      enable = true;
      allowSFTP = false;
      passwordAuthentication = false;
    };
  };

  users = {
    mutableUsers = false;
    users.root.openssh.authorizedKeys.keyFiles = [ ~/.ssh/id_rsa.pub ];
  };
}
