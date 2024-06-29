{ config, ... }:

{
  imports = [
    ./base.nix
  ];

  services.consul = {
    extraConfig = {
      retry_join = [ "nuc.sunrise.box" ];
      server = false;
    };
  };
}
