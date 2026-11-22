# Jellyfin TV appliance
#
# Boots straight into Jellyfin Media Player (packaged as jellyfin-desktop) in
# its TV (10-foot) layout, fullscreen, driven by the TV's remote over HDMI-CEC.
# The Jellyfin *server* runs elsewhere (see modules/media.nix on the nuc); this
# host is only the client on the TV.
{ lib, pkgs, ... }:

let
  # libcec with the Raspberry Pi firmware CEC backend. This Pi runs fake-KMS
  # (hardware/rp4.nix: fkms-3d), where CEC is exposed through the firmware at
  # /dev/vchiq rather than the kernel /dev/cec0 device, so the stock libcec
  # (which only speaks the kernel CEC API) can't drive it.
  libcecRpi = pkgs.libcec.override { withLibraspberrypi = true; };

  # Build Jellyfin Media Player against that libcec so it gets CEC remote input.
  # The override is scoped to this one package on purpose: a global nixpkgs
  # overlay on libcec would force every dependent in the closure to rebuild from
  # source — including the enormous QtWebEngine this app pulls in, which a Pi 4
  # cannot realistically compile. Scoping it keeps QtWebEngine and the rest
  # served from the binary cache; only jellyfin-desktop itself is rebuilt.
  #
  # Pinned ahead of nixpkgs' v2.0.0 to v2.1.0-pre2: v2.0.0 has a first-load race
  # (jellyfin/jellyfin-desktop#1222) where, after the bundled launcher navigates
  # cross-origin to the server's web client, the injected nativeshell user script
  # isn't delivered to the new renderer, so window.NativeShell is missing and the
  # web client never connects to the host input bridge — CEC keys arrive, get
  # mapped, then dropped with "Web Client has not connected". Fixed by commit
  # cabddc6 (PR #1236), which injects the script at the profile level. The stock
  # non-fatal-unique-app patch still applies to this tag.
  jellyfinMediaPlayer =
    (pkgs.jellyfin-media-player.override { libcec = libcecRpi; }).overrideAttrs (_: {
      version = "2.1.0-pre2";
      src = pkgs.fetchFromGitHub {
        owner = "jellyfin";
        repo = "jellyfin-desktop";
        tag = "v2.1.0-pre2";
        fetchSubmodules = true;
        hash = "sha256-yBp9C0y2r8jbkV43Wxph4obJPst6033NAJ2H82cax58=";
      };
    });

  # Input map that turns the CEC key codes libcec delivers (KEY_DOWN, KEY_SELECT,
  # …) into Jellyfin navigation actions. jellyfin-desktop ships this only as an
  # inactive example under inputmaps/examples/, so without it the keys arrive but
  # log "No match for: CEC" and do nothing. "idmatcher" matches the "CEC" source.
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

  # Launcher: the active CEC input map must live in each profile's inputmaps/
  # directory, but profiles are named by a random UUID stored in profiles.json,
  # so we can't hardcode the path. Seed every existing profile on each start,
  # creating a deterministic default profile first if the home is empty (so CEC
  # works on first boot too). Then hand off to the player.
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
  # A single fullscreen Qt app owns the screen, so no desktop or window manager
  # is needed: autologin into a bespoke X session that just launches the player.
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
    # video/render: GPU + CEC device access; audio: HDMI sound.
    extraGroups = [ "video" "render" "audio" ];
  };

  # Audio over HDMI for playback.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # GPU for mpv + QtWebEngine.
  hardware.graphics.enable = true;

  # Grant access to the Raspberry Pi CEC device for the video group.
  services.udev.extraRules = ''
    KERNEL=="vchiq", GROUP="video", MODE="0660", TAG+="systemd", ENV{SYSTEMD_ALIAS}="/dev/vchiq"
  '';

  # cec-client (from the RPi-enabled libcec) is handy for debugging the CEC link.
  environment.systemPackages = [
    jellyfinMediaPlayer
    libcecRpi
  ];
}
