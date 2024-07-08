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

  # https://www.consul.io/docs/install/ports#consul-clients
  networking.firewall.allowedTCPPorts = [ 8301 8500 8600 ];
  networking.firewall.allowedUDPPorts = [ 8301 8600 ];
}
