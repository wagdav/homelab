/* Configuration applied on _all_ machines, that is, desktops and servers. */
{ config, lib, pkgs, nixpkgs, ... }:

{
  networking.firewall.logRefusedConnections = false;

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
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
  };

  # Machine configuration to be added for the vm script produced by ‘nixos-rebuild build-vm’.
  virtualisation.vmVariant = {
    services.qemuGuest.enable = true;
    users.users.dwagner = {
      initialHashedPassword = "";
      isNormalUser = true;
    };
  };

}
