# Deploy ENV

## kubecordA

ip: 140.113.X.171

### Inventory file
```
kubecordA ansible_ssh_host=140.113.X.171 ip=140.113.X.171

[local]
localhost ansible_connection=local

[kube-master]
kubecordA

[etcd]
kubecordA

[kube-node]
kubecordA

[k8s-cluster:children]
kube-master
kube-node

[vault]
kubecordA

[network-setup]
kubecordA

[all:vars]
ansible_port=22
ansible_connection=ssh
ansible_user=root
ansible_pass=
ansible_ssh_private_key_file=inventory/keys/id_rsa
```

### IP

```sh
$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: ens11f0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop portid 8cea1b30da3f state DOWN group default qlen 1000
    link/ether 8c:ea:1b:30:da:3f brd ff:ff:ff:ff:ff:ff
3: enp8s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 8c:ea:1b:30:da:09 brd ff:ff:ff:ff:ff:ff
    inet 140.113.X.171/26 brd 140.113.X.191 scope global enp8s0
       valid_lft forever preferred_lft forever
    inet6 fe80::8eea:1bff:fe30:da09/64 scope link
       valid_lft forever preferred_lft forever
4: ens11f1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop portid 8cea1b30da40 state DOWN group default qlen 1000
    link/ether 8c:ea:1b:30:da:40 brd ff:ff:ff:ff:ff:ff
5: enp9s0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 8c:ea:1b:30:da:0a brd ff:ff:ff:ff:ff:ff
6: ens11f2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop portid 8cea1b30da41 state DOWN group default qlen 1000
    link/ether 8c:ea:1b:30:da:41 brd ff:ff:ff:ff:ff:ff
7: ens11f3: <BROADCAST,MULTICAST> mtu 1500 qdisc noop portid 8cea1b30da42 state DOWN group default qlen 1000
    link/ether 8c:ea:1b:30:da:42 brd ff:ff:ff:ff:ff:ff
```

### Interface Driver Module

```sh
$ ethtool -i enp8s0 | grep ^driver
driver: igb
$ ethtool -i enp9s0 | grep ^driver
driver: igb
$ ethtool -i ens11f0 | grep ^driver
driver: i40e
$ ethtool -i ens11f1 | grep ^driver
driver: i40e
$ ethtool -i ens11f2 | grep ^driver
driver: i40e
$ ethtool -i ens11f3 | grep ^driver
driver: i40e
```

### Devices Infomation

```sh
$ lspci | grep -i Ethernet
01:00.0 Ethernet controller: Intel Corporation Ethernet Controller X710 for 10GbE SFP+ (rev 02)
01:00.1 Ethernet controller: Intel Corporation Ethernet Controller X710 for 10GbE SFP+ (rev 02)
01:00.2 Ethernet controller: Intel Corporation Ethernet Controller X710 for 10GbE SFP+ (rev 02)
01:00.3 Ethernet controller: Intel Corporation Ethernet Controller X710 for 10GbE SFP+ (rev 02)
08:00.0 Ethernet controller: Intel Corporation I210 Gigabit Network Connection (rev 03)
09:00.0 Ethernet controller: Intel Corporation I210 Gigabit Network Connection (rev 03)

$ sudo lshw -class network -businfo
Bus info          Device     Class      Description
===================================================
pci@0000:01:00.0  ens11f0    network    Ethernet Controller X710 for 10GbE SFP+
pci@0000:01:00.1  ens11f1    network    Ethernet Controller X710 for 10GbE SFP+
pci@0000:01:00.2  ens11f2    network    Ethernet Controller X710 for 10GbE SFP+
pci@0000:01:00.3  ens11f3    network    Ethernet Controller X710 for 10GbE SFP+
pci@0000:08:00.0  enp8s0     network    I210 Gigabit Network Connection
pci@0000:09:00.0  enp9s0     network    I210 Gigabit Network Connection
```

### Hugepages

```sh
$ cat /proc/meminfo | grep Huge
AnonHugePages:         0 kB
ShmemHugePages:        0 kB
HugePages_Total:       8
HugePages_Free:        7
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:    1048576 kB
```

### IOMMU

```sh
$ dmesg | grep -e IOMMU
[    0.000000] DMAR: IOMMU enabled
[    0.000000] DMAR-IR: IOAPIC id 3 under DRHD base  0xfbffc000 IOMMU 0
[    0.000000] DMAR-IR: IOAPIC id 1 under DRHD base  0xc7ffc000 IOMMU 1
[    0.000000] DMAR-IR: IOAPIC id 2 under DRHD base  0xc7ffc000 IOMMU 1
```

### SR-IOV VF numbers

```sh
head -n 1 /sys/class/net/*/device/sriov_totalvfs
==> /sys/class/net/ens11f0/device/sriov_totalvfs <==
32

==> /sys/class/net/ens11f1/device/sriov_totalvfs <==
32

==> /sys/class/net/ens11f2/device/sriov_totalvfs <==
32

==> /sys/class/net/ens11f3/device/sriov_totalvfs <==
32
```

## Setup SR-IOV VF

### nctu-cord3

#### Install i40e driver

Dowload: https://downloadcenter.intel.com/zh-tw/download/28306/Intel-pcie-linux-40-

```sh
$ mkdir ~/i40e
$ tar xvfvz i40e-2.4.10.tar.gz -C ~/i40e
$ cd ~/i40e/i40e-2.4.10/src
$ sudo make
$ sudo make install
$ ls /lib/modules/`uname -r`/kernel/drivers/net/ethernet/intel
```

#### modprobe
```sh
echo "options i40e max_vfs=30,30" | sudo tee -a /etc/modprobe.d/i40e.conf
sudo rmmod i40e
sudo modprobe i40e max_vfs=30,30
echo 30 | sudo tee -a /sys/class/net/ens11f0/device/sriov_numvfs
echo 30 | sudo tee -a /sys/class/net/ens11f1/device/sriov_numvfs
```

```sh
$ head -n 1 /sys/class/net/*/device/sriov_numvfs
==> /sys/class/net/ens11f0/device/sriov_numvfs <==
30

==> /sys/class/net/ens11f1/device/sriov_numvfs <==
30

==> /sys/class/net/ens11f2/device/sriov_numvfs <==
0

==> /sys/class/net/ens11f3/device/sriov_numvfs <==
0
```
