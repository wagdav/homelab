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

    $ ansible-galaxy install -r requriements.yml

First time you provision a server

    $ ansibe-playbook bootstrap.yml --ask-pass

Test if all hosts are accessible

    $ ansible -m ping all


## Nomad

The server that runs the nomad exposes the following services:

* Nomad UI: http://nomad:4646
* Consul UI: http://nomad:8500
