# kubecord installer

> Deploy kubecord with kubespray and ansible


## Table of Contents

- [Quick Start for Testing](#quick-start-for-testing)
- [Step by Step for KubeCORD installation](#step-by-step-for-kubecord-installation)
  - [Manchine Requirements](#manchine-requirements)
  - [Preparation work on _each host_](#preparation-work-on-each-host)
    - [DNS server setting](#dns-server-setting)
    - [SSH config setting](#ssh-config-setting)
    - [Root password setting](#root-password-setting)
  - [On _Ansible Control Machine_, install ansible and prepare ssh-key for root](#on-ansible-control-machine-install-ansible-and-prepare-ssh-key-for-root)
    - [1. Download repository and install ansible](#1-download-repository-and-install-ansible)
    - [2. Prepare ssh-key for root](#2-prepare-ssh-key-for-root)
  - [On _Ansible Control Machine_, edit config file](#on-ansible-control-machine-edit-config-file)
    - [1. Edit `inventory/inventory.ini`](#1-edit-inventoryinventoryini)
    - [2. Edit `inventory/group_vars/network-setup.yml`](#2-edit-inventorygroup_varsnetwork-setupyml)
    - [3. Edit `inventory/host_vars/*.yml`](#3-edit-inventoryhost_varsyml)
  - [On _Ansible Control Machine_, start install](#on-ansible-control-machine-start-install)
  - [Reset cluster](#reset-cluster)
- [Check Kubernetes Cluster](#check-kubernetes-cluster)
- [Other Details](#other-details)

## Quick Start for Testing

- Deploy a kubeCORD on localhost with Vagrant and VirtualBox
- Not for production. Test purpose only.
  - [Install Virtualbox](https://www.virtualbox.org/wiki/Downloads)
  - [Install Vagrant](https://www.vagrantup.com/downloads.html)
  - Ref: https://github.com/sufuf3/hands-on-w-tutorials/tree/master/2019-01-03#requirements

```bash
git clone https://github.com/sufuf3/kubecord-installer.git

cd kubecord-installer && sh deploy-in-vagrant.sh
```


## Step by Step for KubeCORD installation
### Manchine Requirements

- Supported OS: Ubuntu 16.04
- Hareware
  - RAM: at least 16 G
  - CPU: 8 cores
- Prepare at least 2 hosts with Ubuntu 16.04
  - One for Ansible Control Machine
  - At least one for Ansible Managed Node to deploy KubeCORD


### Preparation work on _each host_
#### DNS server setting

Edit `/etc/network/interfaces` and reboot every host.  

```sh
dns-nameservers 8.8.8.8
```

#### SSH config setting

1. Edit `/etc/ssh/sshd_config` and update `PermitRootLogin` option to `PermitRootLogin yes`.
2. restart ssh service

```sh
sudo service ssh restart
```

#### Root password setting

```sh
sudo -s
passwd
```

### On _Ansible Control Machine_, install ansible and prepare ssh-key for root
#### 1. Download repository and install ansible

```sh
sudo apt-get install make
cd ~/ && git clone https://github.com/sufuf3/kubecord-installer.git
cd ~/kubecord-installer/
make ansible
```

#### 2. Prepare ssh-key for root

1. generate ssh-key  

```sh
mkdir inventory/keys/ && ssh-keygen -t rsa -b 4096 -C "" -f  inventory/keys/id_rsa -q -N ''
```

2. Put ssh public key to each Ansible Managed Node   

```sh
cat inventory/keys/id_rsa.pub | ssh root@host-ip 'mkdir -p .ssh && cat >> .ssh/authorized_keys'
```

eg.  

```sh
cat inventory/keys/id_rsa.pub | ssh root@192.168.1.2 'mkdir -p .ssh && cat >> .ssh/authorized_keys'
cat inventory/keys/id_rsa.pub | ssh root@192.168.1.3 'mkdir -p .ssh && cat >> .ssh/authorized_keys'
... (for all bare metal servers)
```

3. Test ssh connection  

```sh
ssh root@host-ip -i inventory/keys/id_rsa
```

eg.  

```sh
ssh root@192.168.1.2 -i inventory/keys/id_rsa
```

### On _Ansible Control Machine_, edit config file
#### 1. Edit `inventory/inventory.ini`

For example:  

```
node-1 ansible_ssh_host=10.0.0.224 ip=10.0.0.224
[kube-master]
node-1

[etcd]
node-1

[kube-node]
node-1

[network-setup]
node-1
```

#### 2. Edit `inventory/group_vars/network-setup.yml`

**0. Check on Hugepage each _Ansible Managed Node_**

```sh
ls /sys/devices/system/node/node0/hugepages/hugepages-1048576kB/
ls /sys/devices/system/node/node0/hugepages/hugepages-2048kB/
```

**1. Edit `inventory/group_vars/network-setup.yml`**

- If there is no `/sys/devices/system/node/node0/hugepages/hugepages-1048576kB/` path, update the config as the followings:

```
default_hugepagesz: 2M
nr_hugepages: 1024
```

- Update ovs_access_mode
    - If ovs_access_mode is public, you need to setup `ovs_version` option.
    - If ovs_access_mode is private, you need to setup `ovs_tar_path` & `ovs_folder_name` options.

#### 3. Edit `inventory/host_vars/*.yml`

```sh
$ cp inventory/host_vars/localhost.yml inventory/host_vars/host.yml
```

eg.  

```sh
$ cp inventory/host_vars/localhost.yml inventory/host_vars/node-1.yml
$ cp inventory/host_vars/localhost.yml inventory/host_vars/node-2.yml
```

### On _Ansible Control Machine_, start install

- Use the followings for installing DPDK-OVS & Kubernetes cluster

```sh
make kubecord
```

P.S. If you want to install DPDK-OVS & Kubernetes cluster step by step, please following these steps:  

```sh
# 1. Install DPDK-OVS & support SR-IOV VF
make network-setup

# 2. If you want to add VF number before deploy a Kubernetes cluster, Please setup SR-IOV VF
#    Ref: https://github.com/sufuf3/kubecord/blob/master/docs/setup-kubecord/set-sr-iov.md

# 3. Install Kubernetes cluster
make cluster

# 4. Install SR-IOV & DPDK CNI
make cni-install

# 5. Creating sriov network object
#    Ref: https://github.com/sufuf3/kubecord/blob/master/study/DPDK_SRIOV_CNI/multus-CNI-test.md#try-multus--sriov

# 6. Create pods
#    Ref 1: https://github.com/sufuf3/kubecord/blob/master/study/DPDK_SRIOV_CNI/multus-OVS-DPDK.md#testing-with-dpdk-testpmd-application
#    Ref 2: https://github.com/sufuf3/kubecord/blob/master/study/DPDK_SRIOV_CNI/multus-CNI-test.md#try-multus--sriov
```

### Reset cluster

On _Ansible Control Machine_  

- Reset k8s cluster

```sh
make reset
```

- Reset DPDK-OVS

```sh
ansible-playbook -e "@inventory/group_vars/network-setup.yml" --inventory inventory/inventory.ini network-setup-reset.yml
```

---

## Check KubCORD Cluster

- ssh to _one of k8s master_

```sh
$ cat /etc/lsb-release
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=16.04
DISTRIB_CODENAME=xenial
DISTRIB_DESCRIPTION="Ubuntu 16.04.5 LTS"

$ uname -msr
Linux 4.15.0-34-generic x86_64

$ cat /proc/meminfo | grep Huge
AnonHugePages:         0 kB
ShmemHugePages:        0 kB
HugePages_Total:       8
HugePages_Free:        8
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:    1048576 kB

$ cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
performance
performance
performance
performance
performance
performance
performance
performance
performance
performance
performance
performance

$ sudo ovs-vsctl show
850c9716-cd8e-499f-a071-efe225a8fe20
    ovs_version: "2.9.2"

$ ls /usr/src/dpdk-stable-17.11.4/

$ systemctl status ovsdb-server.service
● ovsdb-server.service - Open vSwitch Database Unit
   Loaded: loaded (/etc/systemd/system/ovsdb-server.service; enabled; vendor preset: enabled)
   Active: active (running) since 二 2018-09-04 11:34:45 CST; 1min 17s ago

$ systemctl status ovs-vswitchd.service
● ovs-vswitchd.service - Open vSwitch Forwarding Unit
   Loaded: loaded (/etc/systemd/system/ovs-vswitchd.service; enabled; vendor preset: enabled)
   Active: active (running) since 二 2018-09-04 11:34:46 CST; 1min 23s ago

$ kubectl get pod -n kube-system
NAME                                       READY   STATUS    RESTARTS   AGE
calico-kube-controllers-5b56bfc96c-klp2z   1/1     Running   0          21d
calico-node-5828t                          1/1     Running   0          21d
calico-node-8z2vn                          1/1     Running   0          21d
coredns-788d98cc7b-49p65                   0/1     Pending   0          21d
coredns-788d98cc7b-sgmq7                   0/1     Pending   0          21d
coredns-788d98cc7b-t4g9v                   1/1     Running   0          21d
coredns-788d98cc7b-zzr9d                   1/1     Running   0          21d
dns-autoscaler-66b95c57d9-nw7xs            1/1     Running   0          21d
kube-apiserver-node-1                      1/1     Running   0          21d
kube-apiserver-node-2                      1/1     Running   0          21d
kube-controller-manager-node-1             1/1     Running   0          21d
kube-controller-manager-node-2             1/1     Running   0          21d
kube-multus-ds-amd64-vd5vt                 1/1     Running   0          21d
kube-multus-ds-amd64-w85b8                 1/1     Running   0          21d
kube-proxy-rmv4q                           1/1     Running   0          21d
kube-proxy-scj4k                           1/1     Running   0          21d
kube-scheduler-node-1                      1/1     Running   0          21d
kube-scheduler-node-2                      1/1     Running   0          21d
kubernetes-dashboard-5db4d9f45f-r485h      1/1     Running   0          21d

$ kubectl get crd
NAME                                             CREATED AT
network-attachment-definitions.k8s.cni.cncf.io   2019-01-22T10:50:23Z

$ kubectl get network-attachment-definition
NAME                   AGE
vhostuser-networkobj   5m

$ ls -l /opt/cni/bin/
total 140688
-rwxr-xr-x 1 root root  3890407 Aug 17  2017 bridge
-rwxr-xr-x 1 root root 28049984 Jan 22 10:49 calico
-rwxr-xr-x 1 root root 27341824 Jan 22 10:49 calico-ipam
-rwxr-xr-x 1 root root  9921982 Aug 17  2017 dhcp
-rwxr-xr-x 1 root root  2814104 Jan 22 10:49 flannel
-rwxr-xr-x 1 root root  2991965 Jan 22 10:49 host-local
-rwxr-xr-x 1 root root  3475802 Aug 17  2017 ipvlan
-rwxr-xr-x 1 root root  3026388 Jan 22 10:49 loopback
-rwxr-xr-x 1 root root  3520724 Aug 17  2017 macvlan
-rwxr-xr-x 1 root root 35071384 Jan 22 10:50 multus
-rw-r--r-- 1 root root     2740 Feb 13 07:16 ovs-config.py
-rwxr-xr-x 1 root root  3470464 Jan 22 10:49 portmap
-rwxr-xr-x 1 root root  3877986 Aug 17  2017 ptp
-rwxr-xr-x 1 root root  2605279 Aug 17  2017 sample
-rwxr-xr-x 1 root root  3897072 Jan 22 11:05 sriov
-rwxr-xr-x 1 root root  2808402 Aug 17  2017 tuning
-rwxr-xr-x 1 root root  3784452 Feb 13 07:16 vhostuser
-rwxr-xr-x 1 root root  3475750 Aug 17  2017 vlan
```

---

## Other Details

- [Kubernetes Basics](https://kubernetes.io/docs/tutorials/kubernetes-basics/)
