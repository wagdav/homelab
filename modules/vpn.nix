{ config, ... }:

{
  services.tailscale.enable = true;
  services.tailscale.interfaceName = if config.boot.isContainer then "userspace-networking" else "tailscale0";
}

