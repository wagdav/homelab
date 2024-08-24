{ config, lib, pkgs, ... }:

{
  imports = [
    ./node-exporter.nix
    ./promtail.nix
  ];

  documentation.enable = false;

  environment.systemPackages = with pkgs; [
    vim
  ];

  nix = {
    extraOptions = ''
      builders-use-substitutes = true
      experimental-features = nix-command flakes
    '';
  };

  nix.gc = {
    automatic = true;
    options = ''--delete-older-than 30d'';
    dates = "weekly";
    randomizedDelaySec = "15min";
  };

  hardware.enableRedistributableFirmware = true;

  i18n.defaultLocale = "en_US.UTF-8";

  time.timeZone = "Europe/Zurich";

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
  };

  users = {
    mutableUsers = false;
    users.root.openssh.authorizedKeys.keys = (import ./keys.nix).dwagner;
  };
}
