{ config, ... }:

{
  services.tailscale.enable = true;
  services.resolved.enable = true; # https://github.com/tailscale/tailscale/issues/4254
}

