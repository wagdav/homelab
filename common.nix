{ config, lib, ... }:

{
  nix.gc.automatic = true;

  i18n.defaultLocale = "en_US.UTF-8";

  time.timeZone = "Europe/Zurich";

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  services = {
    nixosManual.showManual = false;

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
