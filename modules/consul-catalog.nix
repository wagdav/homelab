# Add entries to the Consul Service catalog
{ config, lib, pkgs, ... }:

let

  cfg = config.services.consul;

in
{

  options.services.consul = {
    catalog = lib.mkOption {
      default = [];
      description = ''
        The provided sets are converted to JSON as specified here:
        https://www.consul.io/docs/agent/services
      '';
    };
  };

  config = let
    toServiceDefinition = config:
      pkgs.writeText "${config.name}.json" (builtins.toJSON { service = config; });

    allServices = builtins.map toServiceDefinition cfg.catalog;

  in
    {

      services.consul.extraConfigFiles = builtins.map toString allServices;

    };
}
