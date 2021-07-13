{ revision }:
{ config, lib, pkgs, ... }:

{
  imports = [
    ./consul.nix
    ./node-exporter.nix
    ./promtail.nix
  ];

  documentation.enable = false;

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      builders-use-substitutes = true
      experimental-features = nix-command flakes ca-references
    '';
  };

  nix.gc = {
    automatic = true;
    options = ''--delete-older-than 30d'';
  };

  hardware.enableRedistributableFirmware = true;

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

  system.configurationRevision = revision;

  users = {
    mutableUsers = false;
    users.root.openssh.authorizedKeys.keys = [ (import ./keys.nix).dwagner ];
  };
}
