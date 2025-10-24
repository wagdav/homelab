{ config, lib, pkgs, ... }:

{
  services.radarr = {
    enable = true;
    settings = {
      server.urlbase = "movies";
      auth.method = "External";
    };
  };
  systemd.services.radarr.serviceConfig = {
    StateDirectory = [ "/var/lib/radarr/media" ]; # TODO: need to create it manually
  };
  # Allow radar to see the transmission's Download directory
  users.users.radarr.extraGroups = [ "transmission" ];

  services.prowlarr = {
    enable = true;
    settings = {
      server.urlbase = "indexer";
      auth.method = "External";
    };
  };

  services.transmission = {
    enable = true;
    settings = {
      rpc-host-whitelist-enabled = true;
      rpc-host-whitelist = config.networking.hostName;
    };
  };

  # See issue: https://github.com/NixOS/nixpkgs/issues/258793
  systemd.services.transmission.serviceConfig = {
    RootDirectoryStartOnly = lib.mkForce null;
    RootDirectory = lib.mkForce null;
  };

  services.jellyfin = {
    enable = true;
    # openFirewall = true;  # Use it for first-time config
  };
  # Allow jellyfin to see the media downloaded by radarr
  users.users.jellyfin.extraGroups = [ "radarr" ];
  networking.firewall.allowedUDPPorts = [ 7359 ];

  # HARDWARE ACCELERATION
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-ocl
      intel-media-driver
    ];
  };
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = [ pkgs.libva-utils ];

  systemd.services.jellyfin.environment.LIBVA_DRIVER_NAME = "iHD";
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };

  # FRONTEND
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      radarr = {
        locations = {
          "/${config.services.radarr.settings.server.urlbase}" = {
            proxyPass = "http://127.0.0.1:${toString config.services.radarr.settings.server.port}";
          };
          "/${config.services.prowlarr.settings.server.urlbase}" = {
            proxyPass = "http://127.0.0.1:${toString config.services.prowlarr.settings.server.port}";
          };
          "/transmission" = {
            extraConfig = ''
              proxy_pass_header X-Transmission-Session-Id;
            '';
            proxyPass = "http://127.0.0.1:${toString config.services.transmission.settings.rpc-port}";
          };
          "/stream" = {
            proxyPass = "http://127.0.0.1:8096"; # Jellyfin
          };
        };
      };
    };
  };
  networking.firewall.allowedTCPPorts = [ 80 ];
}
