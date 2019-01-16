#!/bin/bash
# Bring up VMs and deploy k8s with vortex-installer and kubespray 
#
# Dependencies:
# - make
# - virtualbox
# - vagrant

vagrant plugin install vagrant-vbguest vagrant-disksize
vagrant up

vagrant ssh node-1 --command 'https://github.com/sufuf3/kubecord-installer.git'

vagrant ssh node-1 --command 'mkdir -p vortex-installer/inventory/keys'

vagrant ssh node-1 --command 'cp id_rsa vortex-installer/inventory/keys/id_rsa'
vagrant ssh node-1 --command 'cp id_rsa.pub vortex-installer/inventory/keys/id_rsa.pub'

vagrant ssh node-1 --command 'cd kubecord-installer && cp inventory/inventory-vagrant.ini inventory/inventory-vagrant.ini && make ansible cluster'
