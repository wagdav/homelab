# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "x230";
  networking.networkmanager.enable = true;

  networking.useDHCP = false;
  networking.interfaces.enp0s25.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;

  # Set your time zone.
  time.timeZone = "Europe/Zurich";

  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    acpi
    autorandr
    curl
    dmenu
    dropbox-cli
    flameshot
    git
    pass
    rxvt_unicode
    unzip
    urxvt_font_size
    vcsh
    vim
    wget
    xmobar
  ];

  programs.autojump.enable = true;

  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "autojump" "git" "pass" "sudo" ];
    };
  };

  programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the brightness buttons
  services.illum.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable touchpad support.
  services.xserver.libinput.enable = true;
  services.xserver.libinput.accelSpeed = "2";

  services.xserver.windowManager = {
    default = "xmonad";

    xmonad = {
     enable = true;
     enableContribAndExtras = true;
    };
  };

  services.xserver.desktopManager.xterm.enable = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dwagner = {
     isNormalUser = true;
     shell = pkgs.zsh;
     extraGroups = [ "networkmanager" "wheel" ];
  };

  fileSystems."/mnt/nas" = {
    device = "dns-320:/mnt/HD/HD_a2/Ajaxpf";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto"];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?
}
