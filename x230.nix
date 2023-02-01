# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    ./hardware/x230.nix
    ./modules/buildMachines.nix
    ./modules/vpn.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "x230";
    networkmanager.enable = true;

    useDHCP = false;
    interfaces = {
      enp0s25.useDHCP = true;
      wlp3s0.useDHCP = true;
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Zurich";

  nixpkgs.config.allowUnfree = true;

  powerManagement.powertop.enable = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    acpi
    alacritty
    bat
    curl
    dmenu
    #dropbox-cli
    fd
    file
    fim
    firefox
    flameshot
    fzf
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
    wget
    xdg-utils
    zathura
    zoom-us
  ];

  security.wrappers = {
    pmount.source = "${pkgs.pmount}/bin/pmount";
    pmount.owner = "root";
    pmount.group = "root";
    pmount.setuid = true;
    pumount.source = "${pkgs.pmount}/bin/pumount";
    pumount.owner = "root";
    pumount.group = "root";
    pumount.setuid = true;
  };

  programs = {
    autojump.enable = true;

    gnupg.agent = { enable = true; enableSSHSupport = true; };

    sway = {
      enable = true;
      extraSessionCommands = ''
        export MOZ_ENABLE_WAYLAND=1
      '';
    };

    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };

    zsh = {
      enable = true;
      ohMyZsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = [ "autojump" "dirhistory" "fzf" "git" "pass" "sudo" ];
      };
    };
  };

  sound = {
    enable = true;
    mediaKeys.enable = true;
  };

  xdg.portal.wlr.enable = true;

  hardware = {
    enableRedistributableFirmware = true;
    enableAllFirmware = true;

    bluetooth = {
      enable = true;
      package = pkgs.bluezFull;
    };

    pulseaudio = {
      enable = true;
      extraConfig = ''
        # Automatically switch to newly-connected devices
        load-module module-switch-on-connect
      '';
      package = pkgs.pulseaudioFull;
    };

    trackpoint = {
      enable = true;
      speed = 200;
      sensitivity = 200;
    };
  };

  services = {
    illum.enable = true; # Enable the brightness buttons

    openssh.enable = true;

    pipewire.enable = true;

    printing.enable = true;

    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.greetd}/bin/agreety --cmd sway";
        };
      };
    };
  };

  virtualisation.podman.enable = true;
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dwagner = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "dialout" "networkmanager" "vboxusers" "wheel" ];
  };

  fileSystems = {
    "/mnt/nas" = {
      device = "dns-320:/mnt/HD/HD_a2/Ajaxpf";
      fsType = "nfs";
      options = [ "x-systemd.automount" "noauto" "_netdev" ];
    };
  };

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      builders-use-substitutes = true
      experimental-features = nix-command flakes
    '';

    trustedUsers = [ "root" "@wheel" ];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "22.05"; # Did you read the comment?
}
