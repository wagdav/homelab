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
    wget
    zathura
    zoom-us
  ];

  security.wrappers = {
    pmount.source = "${pkgs.pmount}/bin/pmount";
    pumount.source = "${pkgs.pmount}/bin/pumount";
  };

  programs = {
    autojump.enable = true;

    gnupg.agent = { enable = true; enableSSHSupport = true; };

    ssh.knownHosts = {
      nuc = {
        hostNames = [ "nuc" "nuc.thewagner.home" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIKaEtc8PNqhxAQ24gY5t25Y/8HU6StUB6kmU1xmVta7";
      };

      rp3 = {
        hostNames = [ "rp3" "rp3.thewagner.home" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILK0illQrUbCmn+UHgM79tDecSItLUVNuWi/Sg+DW2tr";
      };
    };

    sway.enable = true;

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
        plugins = [ "autojump" "dirhistory" "git" "pass" "sudo" ];
      };
    };
  };

  sound = {
    enable = true;
    mediaKeys.enable = true;
  };

  hardware = {
    enableRedistributableFirmware = true;
    enableAllFirmware = true;

    pulseaudio = {
      enable = true;
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
    distributedBuilds = true;
    buildMachines =
      let
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

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
