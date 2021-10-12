{ config, ... }:

{
  imports = [
    ./base.nix
  ];

  services.consul = {
    extraConfig = {
      server = true;
      bootstrap_expect = 3;
    };
  };
}
