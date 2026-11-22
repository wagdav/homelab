# Jellyfin TV appliance
#
# Boots straight into Jellyfin Media Player (packaged as jellyfin-desktop) in
# its TV (10-foot) layout, fullscreen, driven by the TV's remote over HDMI-CEC.
# The Jellyfin *server* runs elsewhere (see modules/media.nix on the nuc); this
# host is only the client on the TV.
{ lib, pkgs, ... }:

let
  # Pinned ahead of nixpkgs' v2.0.0 to v2.1.0-pre2: for the fix in
  # jellyfin/jellyfin-desktop#1222
  jellyfinMediaPlayer = pkgs.jellyfin-media-player.overrideAttrs (_: {
    version = "2.1.0-pre2";
    src = pkgs.fetchFromGitHub {
      owner = "jellyfin";
      repo = "jellyfin-desktop";
      tag = "v2.1.0-pre2";
      fetchSubmodules = true;
      hash = "sha256-yBp9C0y2r8jbkV43Wxph4obJPst6033NAJ2H82cax58=";
    };
  });

  cecInputMap = pkgs.writeText "cec.json" (builtins.toJSON {
    name = "HDMI CEC";
    idmatcher = "CEC.*";
    mapping = {
      KEY_LEFT = "left";
      KEY_RIGHT = "right";
      KEY_UP = "up";
      KEY_DOWN = "down";
      KEY_SELECT = "enter";
      KEY_BACK = "back";
      KEY_RED = "red";
      KEY_GREEN = "green";
      KEY_YELLOW = "yellow";
      KEY_BLUE = "blue";
      KEY_PLAY = "play";
      KEY_STOP = "stop";
      KEY_PAUSE = "pause";
      KEY_SEEKFWD = "seek_forward";
      KEY_SEEKBCK = "seek_backward";
      KEY_SUBTITLES = "cycle_subtitles";
      KEY_NEXT = "step_forward";
      KEY_PREV = "step_backward";
      KEY_HOME = "home";
      "KEY_NUMERIC_([0-9])" = "%1";
      KEY_GUIDE = "guide";
    };
  });

  launch = pkgs.writeShellScript "jellyfin-tv-launch" ''
    export PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.wireplumber ]}:$PATH

    # Never blank the screen while watching.
    ${pkgs.xset}/bin/xset s off -dpms

    data="$HOME/.local/share/jellyfin-desktop"
    mkdir -p "$data/profiles"
    if [ -z "$(ls -A "$data/profiles" 2>/dev/null)" ]; then
      mkdir -p "$data/profiles/default"
      printf '{"defaultProfile":"default"}\n' > "$data/profiles.json"
      printf '{"name":"Default"}\n' > "$data/profiles/default/profile.json"
    fi
    for p in "$data"/profiles/*/; do
      install -Dm644 ${cecInputMap} "''${p}inputmaps/cec.json"
    done

    # wireplumber brings a fresh HDMI sink up muted-ish at 40%, which makes
    # playback far too quiet. Unmute and set it to full. Retry briefly in case
    # pipewire isn't ready yet at session start.
    for _ in 1 2 3 4 5; do
      wpctl set-volume @DEFAULT_AUDIO_SINK@ 1.0 2>/dev/null && break
      sleep 1
    done
    wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 2>/dev/null || true

    exec ${jellyfinMediaPlayer}/bin/jellyfin-desktop --tv --fullscreen
  '';
in
{
  services.xserver.enable = true;

  services.xserver.desktopManager.session = [
    {
      name = "jellyfin-tv";
      start = "exec ${launch}";
    }
  ];

  services.displayManager = {
    autoLogin = {
      enable = true;
      user = "jellyfin-tv";
    };
    defaultSession = "jellyfin-tv";
  };

  users.users.jellyfin-tv = {
    isNormalUser = true;
    extraGroups = [ "video" "render" "audio" ];
  };

  # Audio over HDMI for playback.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  hardware.graphics.enable = true;

  # Grant the video group access to the kernel CEC device
  services.udev.extraRules = ''
    SUBSYSTEM=="cec", KERNEL=="cec[0-9]*", GROUP="video", MODE="0660"
  '';

  # cec-client is handy for debugging the CEC link from the console.
  environment.systemPackages = [
    jellyfinMediaPlayer
    pkgs.libcec
  ];
}
