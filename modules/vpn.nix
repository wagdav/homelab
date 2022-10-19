{ config, ... }:

{
  services.tailscale.enable = true;

  # Strict reverse path filtering breaks Tailscale exit node use and some
  # subnet routing setups.
  networking.firewall.checkReversePath = "loose";
}

