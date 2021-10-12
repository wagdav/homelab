{ config, ... }:

{
  imports = [
    ./base.nix
  ];

  services.consul = {
    extraConfig = {
      server = false;
    };
  };
}
