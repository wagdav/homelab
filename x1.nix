{ config, lib, pkgs, nixpkgs, disko, nixos-hardware, ... }:

{
  imports = [
    disko.nixosModules.disko
    nixpkgs.nixosModules.notDetected
    nixos-hardware.nixosModules.lenovo-thinkpad-x1-12th-gen
    ./modules/buildMachines.nix
    ./modules/cachix.nix
    ./modules/vpn.nix
  ];

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
    loader.systemd-boot.enable = true;
    kernelModules = [ "kvm-intel" ];
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    # Sound and display need at least kernel 6.8.12, which is not yet supported by the stable ZFS package.
    zfs.package = pkgs.zfs_unstable;
  };

  swapDevices = [ ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  networking = {
    hostName = "x1";
    networkmanager.enable = true;
    hostId = builtins.substring 0 8 (
      builtins.hashString "sha256" config.networking.hostName
    );
  };

  # Workaround for " Failed to start Network Manager Wait Online." after `nixos-rebuild switch`
  # See https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;

  nixpkgs.config.allowUnfree = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  powerManagement.powertop.enable = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    acpi
    bat
    curl
    #dropbox-cli
    fd
    file
    firefox-wayland
    fzf
    git
    gh
    httpie
    moreutils
    mosh
    mpv
    ntfs3g
    pass
    pavucontrol
    pmount
    ripgrep
    tree
    unzip
    vcsh
    wget
    wl-clipboard
    xdg-utils
    zathura
    zoom-us
  ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji
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
      extraPackages = with pkgs; [ swaylock swayidle swayimg foot sway-contrib.grimshot wmenu ];
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

    fprintd.enable = true;

    tailscale.useRoutingFeatures = "client";

    tlp.enable = true;

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

  nix.settings.trusted-users = [ "root" "@wheel" ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "24.05"; # Did you read the comment?

  # Backup
  services.borgbackup.jobs.home = {
    paths = "/home";
    patterns = [
      "+ /home/*/documents"
      "+ /home/*/projects"
      "+ /home/*/.password-store"
      "+ /home/*/.ssh/id_*"
      "+ /home/*/.gnupg/**"
      "- **/*.o"
      "- **/.pyc"
      "- **/.swp"
      "- **"
    ];
    repo = "/mnt/nas/backup/borg/x1";
    encryption.mode = "none";
    doInit = false;
    user = "dwagner";
    startAt = "daily";
    persistentTimer = true;
    prune.keep = {
      within = "1d";
      daily = 7;
      weekly = 4;
      monthly = 12;
      yearly = 10;
    };
  };

  disko.devices = {
    disk = {
      system = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-eui.ace42e003b022f602ee4ac0000000001";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                # Fix world-accessible /boot/loader/random-seed
                # https://github.com/nix-community/disko/issues/527#issuecomment-1924076948
                mountOptions = [ "umask=0077" ];
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "rpool";
              };
            };
          }; # partitions
        }; # content
      }; # system
    }; # disk
    zpool = {
      rpool = {
        type = "zpool";
        rootFsOptions = {
          acltype = "posixacl";
          atime = "off";
          canmount = "off";
          compression = "on";
          mountpoint = "none";
          xattr = "sa";
          "com.sun:auto-snapshot" = "false";
        };

        datasets = {
          local = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          safe = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          "local/log" = {
            type = "zfs_fs";
            mountpoint = "/var/log";
            options = {
              mountpoint = "legacy";
              "com.sun:auto-snapshot" = "true";
            };
          };
          "local/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              atime = "off";
              canmount = "on";
              mountpoint = "legacy";
              "com.sun:auto-snapshot" = "true";
            };
          };
          "local/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options.mountpoint = "legacy";
            postCreateHook = ''
              zfs snapshot rpool/local/root@blank
            '';
          };
          "safe/home" = {
            type = "zfs_fs";
            mountpoint = "/home";
            options = {
              mountpoint = "legacy";
              "com.sun:auto-snapshot" = "true";
            };
          };
          "safe/persist" = {
            type = "zfs_fs";
            mountpoint = "/persist";
            options = {
              mountpoint = "legacy";
              "com.sun:auto-snapshot" = "true";
            };
          };
        }; # datasets
      }; # rpool
    }; # zpool
  }; # disko.devices
}
