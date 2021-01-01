# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    ./hardware/x230.nix
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

  powerManagement.powertop.enable = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    acpi
    alacritty
    curl
    dmenu
    dropbox-cli
    fd
    file
    fim
    firefox
    flameshot
    git
    httpie
    moreutils
    mpv
    pass
    pavucontrol
    pmount
    ripgrep
    tree
    unzip
    vcsh
    vim
    wget
    xmobar
    zathura
  ];

  security.wrappers = {
    pmount.source = "${pkgs.pmount}/bin/pmount";
    pumount.source = "${pkgs.pmount}/bin/pumount";
  };

  programs.autojump.enable = true;

  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "autojump" "dirhistory" "git" "pass" "sudo" ];
    };
  };

  programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    extraConfig = ''
      # Automatically switch to newly-connected devices
      load-module module-switch-on-connect
    '';
    package = pkgs.pulseaudioFull;
  };

  hardware.trackpoint = {
    enable = true;
    speed = 200;
    sensitivity = 200;
  };

  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluezFull;
  };

  # Enable the brightness buttons
  services.illum.enable = true;

  services.autorandr = {
    enable = true;
    defaultTarget = "standalone";
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    autoRepeatDelay = 250;
    autoRepeatInterval = 60;

    # Enable touchpad support.
    libinput = {
      enable = true;
      accelSpeed = "2";
    };

    displayManager.defaultSession = "none+xmonad";

    windowManager = {
      xmonad = {
        enable = true;
        enableContribAndExtras = true;
      };
    };
  };

  virtualisation.podman.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dwagner = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "dialout" "networkmanager" "wheel" ];
  };

  fileSystems = {
    "/mnt/nas" = {
      device = "dns-320:/mnt/HD/HD_a2/Ajaxpf";
      fsType = "nfs";
      options = [ "x-systemd.automount" "noauto" ];
    };

    "/mnt/nook" = {
      device = "/dev/disk/by-uuid/C701-B45D";
      fsType = "vfat";
      options = [ "x-systemd.automount" "noauto" ];
    };

    "/mnt/pocketdrive" = {
      device = "/dev/disk/by-uuid/8f9d722f-281a-4647-a084-94b0510cfb7a";
      fsType = "ext3";
      options = [ "x-systemd.automount" "noauto" ];
    };

    "/mnt/wd-elements" = {
      device = "/dev/disk/by-uuid/4743da06-ca4c-4879-8126-fb1308263b88";
      fsType = "ext4";
      options = [ "x-systemd.automount" "noauto" ];
    };

  };

  nix = {
    distributedBuilds = true;
    buildMachines = let
      sshUser = "root";
      sshKey = "/root/remote-builder";
    in
      [
        {
          hostName = "nuc.thewagner.home";
          systems = [ "x86_64-linux" "i686-linux" "aarch64-linux" ];
          maxJobs = 4;
          inherit sshUser sshKey;
        }
        {
          hostName = "rp3.thewagner.home";
          system = "aarch64-linux";
          maxJobs = 4;
          inherit sshUser sshKey;
        }
      ];
    package = pkgs.nixUnstable;
    extraOptions = ''
      builders-use-substitutes = true
      experimental-features = nix-command flakes ca-references
    '';

    trustedUsers = [ "root" "@wheel" ];
  };

  programs.ssh.knownHosts = {
    nuc = {
      hostNames = [ "nuc" "nuc.thewagner.home" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIKaEtc8PNqhxAQ24gY5t25Y/8HU6StUB6kmU1xmVta7";
    };

    rp3 = {
      hostNames = [ "rp3" "rp3.thewagner.home" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILK0illQrUbCmn+UHgM79tDecSItLUVNuWi/Sg+DW2tr";
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
