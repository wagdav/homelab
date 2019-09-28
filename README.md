# Infrastructure configuration

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
