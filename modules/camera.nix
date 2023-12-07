{ config, ... }:

{
  services.mjpg-streamer.enable = true;
  services.mjpg-streamer.inputPlugin = "input_uvc.so -vf true";
  networking.firewall.allowedTCPPorts = [ 5050 ];
}
