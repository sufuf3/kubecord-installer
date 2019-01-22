clean:
	rm -rf *.log *.zip *.retry kubecord-installer

submodule:
	git submodule init && git submodule update

.PHONY: ansible
UNAME := $(shell uname)
PORT := $(shell which port)
BREW := $(shell which brew)
ifeq ($(UNAME), Linux)

ansible: submodule
	sudo apt-get upgrade -y && \
		sudo apt-get update && \
		sudo apt-get install -y python3 python3-pip jq
	export LC_ALL=C && \
		sudo pip3 install --upgrade pip && \
		sudo pip3 install --upgrade yq ansible netaddr cryptography && \
		sudo pip3 install -r kubespray/requirements.txt

else ifeq ($(UNAME), Darwin)

ansible: submodule
	if [[ "$(PORT)" != "" ]]; then sudo port install jq coreutils; fi
	if [[ "$(BREW)" != "" ]]; then brew install jq coreutils; fi
	rehash
	sudo pip3 install --upgrade yq ansible netaddr cryptography && \
	sudo pip3 install -r kubespray/requirements.txt

endif

# infrastructure
.PHONY: vagrant
vagrant:
	cd vagrant/ && sh deploy-in-vagrant.sh

vagrant-destroy:
	cd vagrant/ && vagrant destroy -f

# all: main target workflow
all: submodule cluster

config-kubespray:
	mkdir -p kubespray/inventory/kubecord 
	cp -r inventory/group_vars kubespray/inventory/kubecord
	cp inventory/inventory.ini kubespray/inventory/kubecord/hosts.ini

# deploy kubernetes with kubespray
# FIXME make cluster will cause tty pipe line error. Use bash script instead.
.PHONY: cluster
cluster: config-kubespray
	ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook \
		-e "@inventory/group_vars/all.yml" \
		-e "@inventory/group_vars/k8s-cluster.yml" \
		--inventory inventory/inventory.ini \
		cluster.yml

.PHONY: scale
scale: config-kubespray
	ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook \
		--inventory inventory/inventory.ini \
		kubespray/scale.yml 2>&1 | tee $(shell date +%F-%H%M%S)-scale.log

.PHONY: cluster
kubecord: config-kubespray
	ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook \
		-e "@inventory/group_vars/all.yml" \
		-e "@inventory/group_vars/k8s-cluster.yml" \
		-e "@inventory/group_vars/network-setup.yml" \
		--inventory inventory/inventory.ini \
		kubecord.yml 2>&1 | tee $(shell date +%F-%H%M%S)-kubecord.log

network-setup:
	ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook \
		-e "@inventory/group_vars/network-setup.yml" \
		--inventory inventory/inventory.ini \
		network-setup.yml 2>&1 | tee $(shell date +%F-%H%M%S)-network-setup.log

network-setup-reset:
	ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook \
		-e "@inventory/group_vars/network-setup.yml" \
		--inventory inventory/inventory.ini \
		network-setup-reset.yml 2>&1 | tee $(shell date +%F-%H%M%S)-network-setup-reset.log

cni-install:
	ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook \
		-e "@inventory/group_vars/network-setup.yml" \
		--inventory inventory/inventory.ini \
		cni-install.yml 2>&1 | tee $(shell date +%F-%H%M%S)-cni-install.log

# reset kubernetes cluster with kubespray
.PHONY: reset
reset: config-kubespray
	ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook \
		-e reset_confirmation=yes \
		--inventory inventory/inventory.ini \
		kubespray/reset.yml 2>&1 | tee $(shell date +%F-%H%M%S)-reset.log
