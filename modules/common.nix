{ config, lib, pkgs, ... }:

{
  nix.gc = {
    automatic = true;
    options = ''--max-freed "$((10 * 1024**3 - 1024 * $(df -P -k /nix/store | tail -n 1 | ${pkgs.gawk}/bin/awk '{ print $4 }')))"'';
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
