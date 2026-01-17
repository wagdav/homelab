{ config, ... }:

{
  imports = [
    ./base.nix
  ];

  services.consul = {
    interface.bind = "mv-0";
    extraConfig = {
      server = true;
      bootstrap_expect = 1;
    };
  };

  # https://www.consul.io/docs/install/ports#consul-servers
  networking.firewall.allowedTCPPorts = [ 8300 8301 8302 8503 8500 8600 ];
  networking.firewall.allowedUDPPorts = [ 8600 8301 8302 ];
}
