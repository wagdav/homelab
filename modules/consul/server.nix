{ config, ... }:

{
  imports = [
    ./base.nix
  ];

  services.consul = {
    interface.bind = "eno1";
    extraConfig = {
      server = true;
      bootstrap_expect = 1;
    };
  };
}
