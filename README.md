# Homelab

The configuration of my home infrastructure.

## Laptop

My main laptop, a Lenovo X230, runs [NixOS](https://nixos.org/).

Its configuration is specified in `x230.nix` using the [experimental flakes
feature](https://www.tweag.io/blog/2020-07-31-nixos-flakes/).  Modify this file
and switch to the new configuration:

```
sudo nixos-rebuild switch --flake .
```

By default, this configuration is stored in `/etc/nixos/configuration.nix`.

For testing purposes you can build a QEMU virtual machine from the configuration:

```
nixos-rebuild build-vm --flake .
```

To update the lock files:

```
nix flake update --update-input nixpkgs --commit-lock-file
```

My [rcfiles](https://github.com/wagdav/rcfiles) repository completes the
configuration of my laptop.  Those files live in a separate repository because
I also use them on my work computer which doesn't run NixOS.

## Servers

The entrypoint for my home server setup is [home.nix](home.nix).  This
configuration is deployed using [nixops](https://github.com/NixOS/nixops).  A
one-time setup is required if the deployment doesn't exist yet:

```
nix develop -c nixops create --name home
```

Then, run the following command to deploy:

```
nix develop -c nixops deploy
```

This builds the system configurations locally and copies the resulting closures
to the remote machines.

## Logs

All server send their logs to [Loki](https://grafana.com/oss/loki/).  To see
all logs live:

```
export LOKI_ADDR=http://loki.thewagner.home
nix shell nixpkgs#grafana-loki --command \
    logcli query '{job="systemd-journald"}' --tail
```

The `query` command takes a
[LogQL](https://grafana.com/docs/loki/latest/logql/) expression as an argument.

## Installing a new NixOS system

Installing a new system takes only a few manual steps.

Create a customized installer ISO image using the command mentioned at the top
of [installer/iso.nix](installer/iso.nix).

Copy the ISO image to a USB stick and boot the computer from it.  Connect to
the installer using SSH:

```
ssh root@nixos -o StrictHostKeyChecking=no -o 'UserKnownHostsFile /dev/null'
```

Execute the relevant lines from [/etc/install.sh](installer/install.sh) to
partition the disk and create file systems.

Use the basic configuration from
[/etc/configuration.nix](installer/configuration.nix) as default and set the
hostname.

Run the installer then reboot the machine.  The installation of the basic
system is done.

Continue the system's management using NixOps.

### Useful commands

The configuration.nix(5) man page documents all the available options for
configuring the system:

```
man configuration.nix
```

All supported options are searchable [online](https://nixos.org/nixos/options.html).

Query available packages:

```
nix search nixpkgs wget
```

[Install a package](https://nixos.wiki/wiki/Nix_command/profile_install) into
the user's profile

```
nix profile install nixpkgs#firefox
```

Remove old, unreferenced packages, system-wide:

```
sudo nix-collect-garbage
sudo nix-collect-garbage -d  # also delete old system old configurations
```

This is documented in the [Cleaning the Nix Store](https://nixos.org/nixos/manual/index.html#sec-nix-gc)
section of the NixOS manual.

The builtin functions of the Nix evaulator are listed
[here](https://nixos.org/nix/manual/#ssec-builtins).

See the version of this repository from which the system's configuration was
built:

```
nixos-version --json
```

## Router

Linksys WRT ACM-3200 running OpenWRT.

### First time setup

Connect to the router with an Ethernet cable.

Download and install the [OpenWRT
firmware](https://openwrt.org/toh/linksys/wrt3200acm) then run:

```
router/setup.sh --first-time
```

Reboot the router.

### Customizations

Change the settings in `router/config` and run

```
router/setup.sh
```

## Raspberry Pi 3 Model B

### Raspbian

Setup SD card:

```
wget https://downloads.raspberrypi.org/raspbian_lite_latest
unzip -p raspbian_lite_latest | sudo dd of=/dev/mmcblk0 bs=4M conv=fsync status=progress
# remove then reinsert SD card
pmount /dev/mmcblk0p1
touch /media/mmcblk0p1/ssh
pumount /dev/mmcblk0p1
```

### NixOS

The official NixOS images boot without any problems.  Download the latest
aarch64 SD card image from
[Hydra](https://hydra.nixos.org/search?query=sd_image).

Flash the image to an SD card as described in the [previous section](#raspbian).

Boot the system then start an SSH server and set a temporary password for the
root user:

```
systemctl start sshd
passwd root
```

The password is only used for the first time access.  Password authentication
will be disabled later.  Connect to the freshly booted system using SSH.

If you want to manage Pi using NixOps, there's some extra steps required.

NixOps compiles all managed systems on the control PC where it runs. Then, it
copies the binaries to the target systems.  This works well for i686 and amd64
architectures but it doesn't work for aarch64.

I tried to setup cross-compilation to aarch64, but it didn't work.

The trick is to add the newly created Raspberry Pi as an aarch64 [remote build
machine for Nix](https://nixos.org/nix/manual/#chap-distributed-builds).  This
way the required packages will be built natively on the Pi itself (or other
aarch64 remote build nodes, if you have any).  In practice, almost nothing is
built from source, because the required derivations are pulled from the offical
Nix binary cache.

See the section `nix.buildMachines` in [x230.nix](x230.nix), which shows how to
add the Pi to your control PC's remote build pool.  Enable some Raspberry Pi
specific arguments in the [hardware specification](hardware/rp3.nix) and use
NixOps as usual.

## NodeMCU

I have a couple of NodeMCU boards which can be configured using the scripts in
the [nodemcu](nodemcu) directory.

Enter a Nix shell

```
cd nodemcu
nix-shell
```

In this shell the following helper functions are available.

Erase everything from the device and start from scratch:

* `flash_erase`: Perform Chip Erase on SPI flash
* `flash_write`: Write the [Tasmota firmware](
   https://github.com/arendst/Tasmota) to the device

Open an interactive serial terminal:

```
serial_terminal
```

Restore the firmware's factory settings:

```
device_reset | commit
```

Configure a device

```
device_config <WIFI_SSID> <WIFI_KEY> | commit
```

These commands are defined as [shell hooks in shell.nix](./nodemcu/shell.nix)

### Provisioning

The best way I found to provision the ESP8266 systems with custom firmware is
through MQTT because it's not always easy to get access to a serial terminal.

Use the serial console or the web interface to connect the device to the WiFi
and to the MQTT broker.

Build and run any of the [provisioning scripts](nodemcu/provision.nix):

```shell
nix build .#sensors && ./result/tasmota_082320.sh
```

This will reconfigure the specified sensor by sending
[commands](https://tasmota.github.io/docs/Commands/) over MQTT.

### Dashboard

On my mobile I created a dashboard using [MQTT Dash](https://play.google.com/store/apps/details?id=net.routix.mqttdash&gl=US).

To update the [dashboard configuration](nodemcu/mqtt-dash.json) file, use the
Import/Export functionality of the app and publish the dashboard state to an
MQTT topic (the default is `metrics/exchange`).

The following command listens to the published configuration and updates the
dashboard configuration in this repository:

```
nix run .#mqtt-dash-listen > nodemcu/mqtt-dash.json
```
