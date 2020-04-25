# Homelab

The configuration of my home infrastructure.

## Laptop

My main laptop, a Lenovo X230, runs [NixOS](https://nixos.org/).

Its configuration is specified in `x230.nix`.  Modify this file and deploy the
new configuration:

    sudo nixos-rebuild -I nixos-config=x230.nix switch

By default, this configuration is stored in `/etc/nixos/configuration.nix`.

For testing purposes you can build a QEMU virtual machine from the configuration:

    nixos-rebuild -I nixos-config=x230.nix build-vm

## Servers

The entrypoint for my home server setup is [home.nix](home.nix).  Modify that
expression and deploy:

    nixops deploy

This will build the system configurations locally and copy the resulting
closures to the remote machines.

## Installing a new NixOS system

Installing a new system takes only a few manual steps.

Create a customized installer ISO image using the command mentioned at the top
of [installer/iso.nix](installer/iso.nix).

Copy the ISO image to a USB stick and boot the computer from it.  Connect to
the installer using SSH:

    ssh root@nixos -o StrictHostKeyChecking=no -o 'UserKnownHostsFile /dev/null'

Execute the relevant lines from [/etc/install.sh](installer/install.sh) to
partition the disk and create file systems.

Use the basic configuration from
[/etc/configuration.nix](installer/configuration.nix) as default and set the
hostname.

Run the installer then reboot the machine.  The installation of the basic
system is done.

Continue the systems's management using NixOps.


### Useful commands

The configuration.nix(5) man page documents all the available options for configuring the system:

    man configuration.nix

All supported options are searchable online:

    https://nixos.org/nixos/options.html

Query available packages:

    nix search wget

Remove old, unreferenced packages, system-wide:

    sudo nix-collect-garbage
    sudo nix-collect-garbage -d  # also delete old system old configurations

This is documented in the [Cleaning the Nix Store](https://nixos.org/nixos/manual/index.html#sec-nix-gc)
section of the NixOS manual.

The builtin functions of the Nix evaulator:

    https://nixos.org/nix/manual/#ssec-builtins

## Router

Linksys WRT ACM-3200 running OpenWRT.

### First time setup

Connect to the router with an Ethernet cable.

Download and install the firmware from https://openwrt.org/toh/linksys/linksys_wrt3200acm then run:

    router/setup.sh --first-time

Reboot the router.

### Customizations

Change the settings in `router/config` and run

    router/setup.sh

## Raspberry PI

Setup SD card:

    wget https://downloads.raspberrypi.org/raspbian_lite_latest
    unzip -p raspbian_lite_latest | sudo dd of=/dev/mmcblk0 bs=4M conv=fsync status=progress
    # remove then reinsert SD card
    pmount /dev/mmcblk0p1
    touch /media/mmcblk0p1/ssh
    pumount /dev/mmcblk0p1
