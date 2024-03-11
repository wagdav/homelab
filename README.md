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

The server's configuration is in the `nixosConfigurations` attribute of
[flake.nix](flake.nix).  Use [this  script](./scripts/switch.sh), a thin
wrapper around `nixos-rebuild`, to build and activate a server's configuration:

```
./scripts/switch.sh nuc  # redeploy the server nuc
```

### Logs

All server send their logs to [Loki](https://grafana.com/oss/loki/).  To see
all logs live:

```
export LOKI_ADDR=http://loki.thewagner.home
nix shell nixpkgs#grafana-loki --command \
    logcli query '{job="systemd-journald"}' --tail
```

The `query` command takes a
[LogQL](https://grafana.com/docs/loki/latest/logql/) expression as an argument.

### Continuous deployment

Each commit on the master branch is automatically deployed using [Cachix
Deploy](https://blog.cachix.org/posts/2022-07-29-cachix-deploy-public-beta/).
For a detailed description see [this blog
post](https://thewagner.net/blog/2023/11/25/homelab-deployment/).

To prepare a machine for automatic deployment:

1. Add the system's derivation to the `cachix-deploy` package in
   [flake.nix](./flake.nix)
1. Install `cachix-agent` by including [this module](./modules/cachix.nix)
1. In the Cachix Deploy console follow the "Add Agent" steps
1. Save the generated agent token in `/etc/cachix-agent.token` using the format
   `CACHIX_AGENT_TOKEN=<token>`

The deployment steps are defined in [this
file](.github/workflows/build-and-deploy.yml).  The Cachix Deploy documentation
describe how to configure GitHub Actions.  The pipeline uses the following
values as [action
secrets](https://github.com/wagdav/homelab/settings/secrets/actions):

* `CACHIX_AUTH_TOKEN`
* `CACHIX_ACTIVATE_TOKEN`

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

## Useful commands

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

See which version of a given package will be installed:

```
$ nix eval .#nixosConfigurations.nuc.pkgs.grafana.version
"10.2.4"
```

Evaluate configuration parameters:

```
$ nix eval .#nixosConfigurations.nuc.config.networking.firewall.allowedTCPPorts
[ 22 80 1883 3000 3100 8022 8080 8081 8300 8301 8302 8500 8600 9000 9080 9090
9093 9100 9883 ]
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

### SD card image

Build the Raspberry Pi's SD card image using QEMU's aarch64 emulator.

On `x230`, because `nuc` [is configured](./hardware/nuc.nix) as a remote builder
for `aarch64` packages, just run:

```
nix build .#packages.aarch64-linux.sdcard
```

On other hosts, specify `nuc` explicitly as a remote builder:

```
nix build -L .#packages.aarch64-linux.sdcard \
  --builders "ssh://root@nuc aarch64-linux $HOME/.ssh/remote-builder 4 1 - - c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUlLYUV0YzhQTnFoeEFRMjRnWTV0MjVZLzhIVTZTdFVCNmttVTF4bVZ0YTcgcm9vdEBudWMK"
```

The elements of `--builders` argument are described [here][NixOSRemoteBuilds].

Uncompress the built image and write it to an SD card:

```
unzstd nixos-sd-image.img.zst
sudo dd  if=nixos-sd-image.img of=/dev/mmcblk0 bs=4096 conv=fsync status=progress
```

Insert the SD card in the Raspberry Pi and power it up.  The system is
configured as defined in [host-rp3.nix](./host-rp3.nix).

### Secrets

If the SD card is build from scratch, change or provision the following
secrets:

* Host's identity (automatically generated on first boot)
* WiFi SSID and password in `/etc/secrets/wireless.env`
* Tailscale authentication token
* Cachix authentication token

If this is a complete reinstall, update the host's public key in
[program.ssh.knownHosts](./modules/buildMachines.nix).  Run `ssh-keygen rp3` to
obtain the host key's signature.

Store the WIFI SSID and password in the file `/etc/secrets/wireless.env` with
the following format:

```
WIFI_SSID=...
WIFI_KEY=...
```

Connect the host to the tailnet with `tailscale login`.

To connect Cachix, follow [these instructions](#continuous-deployment).

### Raspberry Pi Camera 1.3

The firmware configuration is _not_ managed by Nix, the following manual edit
is required.  Mount the firmware partition:

```
mount /dev/disk/by-label/FIRMWARE /mnt
```

And add the following lines to `/mnt/config.txt`:

```
start_x=1
gpu_mem=256
```

Save the changes and reboot the Pi:

```
umount /mnt
reboot
```

Stream a live video stream over SSH:

```
ssh root@rp3 \
    nix run nixpkgs#ffmpeg -- \
        -an -f video4linux2 -s 640x480 -i /dev/video0 -r 10 -b:v 500k \
        -f matroska - | \
    nix run nixpkgs#mpv -- --demuxer=mkv /dev/stdin
```

### Reference

I found the following links useful:

* [nix.dev](https://nix.dev/tutorials/nixos/installing-nixos-on-a-raspberry-pi.html)
  on installing NixOS on the Raspberry Pi.
* [Hydra](https://hydra.nixos.org/search?query=sd_image) hosts the official
  NixOS SD card images.

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

[NixOSBootWifi]: https://nixos.org/manual/nixos/stable/#sec-installation-booting-networking
[NixOSRemoteBuilds]: https://nixos.org/manual/nix/stable/advanced-topics/distributed-builds.html?highlight=builders#remote-builds).
