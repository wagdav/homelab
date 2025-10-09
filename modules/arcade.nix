{ config, pkgs, lib, ... }:

{
  nixpkgs.config.allowUnfree = true;

  services.xserver.enable = true;
  services.xserver.desktopManager.retroarch = {
    enable = true;
    package = (pkgs.retroarch.withCores (cores: with cores; [
      genesis-plus-gx
      snes9x
    ]));
  };

  hardware.bluetooth.enable = true;

  services.pipewire.pulse.enable = true;

  users.users.gamer = {
    isNormalUser = true;
    extraGroups = [ "video" ];
  };
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "gamer";
  services.xserver.displayManager.startx.extraCommands = ''
    xset s off  # Disable screen-saver
  '';

  # CEC
  nixpkgs.overlays = [
    (self: super: { libcec = super.libcec.override { withLibraspberrypi = true; }; })
  ];

  environment.systemPackages = with pkgs; [
    libcec
  ];

  services.udev.extraRules = ''
    # allow access to raspi cec device for video group (and optionally register it as a systemd device, used below)
    KERNEL=="vchiq", GROUP="video", MODE="0660", TAG+="systemd", ENV{SYSTEMD_ALIAS}="/dev/vchiq"
  '';
}
