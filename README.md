# Homelab

The configuration of my home infrastructure.

## Getting started

Create a Python virtual environment and install requirements:

    $ mkvirtualenv -p `which python3` infra2
    (infra2) $ pip install -r requirements.txt

In the following it is assumed that the virtual environment is always activated.


## Ansible

The following commands are executed in the ./ansible/ subdirectory.


### Bootstrapping

Install ansible galaxy modules

    $ ansible-galaxy install -r requirements.yml

First time you provision a server, add it to the inventory and re-run the main playbook

    $ ansibe-playbook site.yml
    $ ansibe-playbook site.yml --tags bootstrap

Test if all hosts are accessible

    $ ansible -m ping all


## Nomad

The server that runs the nomad exposes the following services:

* Nomad UI: http://nomad:4646
* Consul UI: http://nomad:8500


## Raspberry PI

Setup SD card:

    wget https://downloads.raspberrypi.org/raspbian_lite_latest
    unzip -p raspbian_lite_latest | sudo dd of=/dev/mmcblk0 bs=4M conv=fsync status=progress
    # remove then reinsert SD card
    pmount /dev/mmcblk0p1
    touch /media/mmcblk0p1/ssh
    pumount /dev/mmcblk0p1

## Laptop

My main laptop, a Lenovo X230, runs [NixOS](https://nixos.org/).

Its configuration is specified in `x230.nix`.  Modify this file and deploy the
new configuration:

    sudo nixos-rebuild -I nixos-config=x230.nix switch

By default, this configuration is stored in `/etc/nixos/configuration.nix`.

For testing purposes you can build a QEMU virtual machine from the configuration:

    nixos-rebuild -I nixos-config=x230.nix build-vm


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
