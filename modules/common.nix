/* Configuration applied on _all_ machines, that is, desktops and servers. */
{ config, lib, pkgs, nixpkgs, ... }:

{
  nix = {
    extraOptions = ''
      builders-use-substitutes = true
      experimental-features = nix-command flakes
    '';

    registry.nixpkgs.flake = nixpkgs;

    gc = {
      automatic = true;
      options = ''--delete-older-than 30d'';
      dates = "weekly";
      randomizedDelaySec = "15min";
    };
  };

  i18n.defaultLocale = "en_US.UTF-8";

  time.timeZone = "Europe/Zurich";

  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
  };
}
