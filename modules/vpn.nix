{ config, ... }:

{
  services.tailscale.enable = true;
  services.tailscale.interfaceName = if config.boot.isContainer then "userspace-networking" else "tailscale0";
  services.tailscale.openFirewall = config.boot.isContainer;
  services.resolved.enable = true; # Recommended in https://github.com/tailscale/tailscale/issues/4254
}

