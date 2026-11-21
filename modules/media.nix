{ config, lib, pkgs, ... }:

let
  # radarr, sonarr and bazarr all create files under the shared media tree; a
  # 0002 umask keeps them group-writable so the services can read and write
  # each other's media and subtitles. mkForce overrides the servarr modules'
  # default 0022 (bazarr sets no default of its own).
  mediaUmask = lib.mkForce "0002";
in
{
  services.radarr = {
    enable = true;
    settings = {
      server.urlbase = "movies";
      auth.method = "External";
    };
  };
  systemd.services.radarr.serviceConfig = {
    StateDirectory = [ "/var/lib/radarr/media" ];
    UMask = mediaUmask;
  };
  # Allow radar to see the transmission's Download directory
  users.users.radarr.extraGroups = [ "transmission" ];

  services.sonarr = {
    enable = true;
    settings = {
      server.urlbase = "series";
      auth.method = "External";
    };
  };
  systemd.services.sonarr.serviceConfig = {
    StateDirectory = [ "/var/lib/sonarr/media" ];
    UMask = mediaUmask;
  };
  # Allow sonarr to see the transmission's Download directory
  users.users.sonarr.extraGroups = [ "transmission" ];

  services.prowlarr = {
    enable = true;
    settings = {
      server.urlbase = "indexer";
      auth.method = "External";
    };
  };

  services.bazarr = {
    enable = true;
    # Bazarr has no declarative `settings` option: configure the base URL
    # (Settings > General > URL Base = "/subs") and authentication through
    # the web UI. To configure bazarr the first time, open the port 6767.
  };
  # Allow bazarr to see the media managed by radarr/sonarr so it can fetch
  # and write subtitles alongside it.
  users.users.bazarr.extraGroups = [ "radarr" "sonarr" ];
  # Write subtitles group-readable so jellyfin (also a group member) can read them.
  systemd.services.bazarr.serviceConfig.UMask = mediaUmask;

  # Create the shared media directories group-writable with the setgid bit, so
  # files bazarr (a member of the radarr/sonarr groups) creates inherit the
  # directory's group and stay accessible to the others.
  systemd.tmpfiles.rules = [
    "d /var/lib/radarr/media 2775 radarr radarr -"
    "d /var/lib/sonarr/media 2775 sonarr sonarr -"
  ];

  services.transmission = {
    enable = true;
    package = pkgs.transmission_4;
    settings = {
      rpc-host-whitelist-enabled = true;
      rpc-host-whitelist = config.networking.hostName;
      ratio-limit-enabled = true;
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
  # Allow jellyfin to see the media downloaded by radarr/sonarr
  users.users.jellyfin.extraGroups = lib.mkForce [ "radarr" "sonarr" "render" ];
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
          "/${config.services.sonarr.settings.server.urlbase}" = {
            proxyPass = "http://127.0.0.1:${toString config.services.sonarr.settings.server.port}";
          };
          "/subs" = {
            proxyPass = "http://127.0.0.1:${toString config.services.bazarr.listenPort}";
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
