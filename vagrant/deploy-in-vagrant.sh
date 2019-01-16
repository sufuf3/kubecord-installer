#!/bin/bash
# Bring up VMs and deploy k8s with vortex-installer and kubespray 
#
# Dependencies:
# - make
# - virtualbox
# - vagrant

#vagrant plugin install vagrant-vbguest vagrant-disksize
#vagrant up

vagrant ssh node-1 --command 'git clone https://github.com/sufuf3/kubecord-installer.git'

vagrant ssh node-1 --command 'mkdir -p kubecord-installer/inventory/keys'

vagrant ssh node-1 --command 'cp id_rsa kubecord-installer/inventory/keys/id_rsa'
vagrant ssh node-1 --command 'cp id_rsa.pub kubecord-installer/inventory/keys/id_rsa.pub'

vagrant ssh node-1 --command 'cd kubecord-installer && cp inventory/inventory-vagrant.ini inventory/inventory.ini && make ansible cluster'
