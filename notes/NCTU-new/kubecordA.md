# Deploy ENV

## kubecordA

ip: 140.113.X.171

### Inventory file
```
kubecord-a ansible_ssh_host=140.113.X.171 ip=140.113.X.171

[local]
localhost ansible_connection=local

[kube-master]
kubecord-a

[etcd]
kubecord-a

[kube-node]
kubecord-a

[k8s-cluster:children]
kube-master
kube-node

[vault]
kubecord-a

[network-setup]
kubecord-a

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

### kubecord-a

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

#### Update Firmware

Download: https://downloadcenter.intel.com/download/24769/Non-Volatile-Memory-NVM-Update-Utility-for-Intel-Ethernet-Network-Adapter-710-Series?product=82947

```sh
$ mkdir ~/NVM

$ unzip NVMUpdatePackage_710_Series.zip
Archive:  NVMUpdatePackage_710_Series.zip
   creating: 710_Series/
  inflating: 710_Series/XL710_NVMUpdatePackage_v6_80_EFI.zip
  inflating: 710_Series/XL710_NVMUpdatePackage_v6_80_ESX.tar.gz
  inflating: 710_Series/XL710_NVMUpdatePackage_v6_80_FreeBSD.tar.gz
  inflating: 710_Series/XL710_NVMUpdatePackage_v6_80_Linux.tar.gz
  inflating: 710_Series/XL710_NVMUpdatePackage_v6_80_Windows.exe

$ mv ~/710_Series/XL710_NVMUpdatePackage_v6_80_Linux.tar.gz ~/.
$ tar xvfvz XL710_NVMUpdatePackage_v6_80_Linux.tar.gz -C ~/NVM/

$ cd ~/NVM/XL710/Linux_x64
$ chmod 755 nvmupdate64e
$ chmod 755 nvmupdate.cfg
$ ls -al | grep nvmupdate
-rwxr-xr-x 1 winlab winlab 4179827 Nov 13 11:24 nvmupdate64e
-rwxr-xr-x 1 winlab winlab   22284 Nov 13 11:18 nvmupdate.cfg

$ sudo ./nvmupdate64e

Intel(R) Ethernet NVM Update Tool
NVMUpdate version 1.32.20.30
Copyright (C) 2013 - 2018 Intel Corporation.


WARNING: To avoid damage to your device, do not stop the update or reboot or power off the system during this update.
Inventory in progress. Please wait [****|.....]


Num Description                          Ver.(hex)  DevId S:B    Status
=== ================================== ============ ===== ====== ==============
01) Intel(R) Ethernet Converged          5.02(5.02)  1572 00:001 Update
    Network Adapter X710                                         available
02) Intel(R) I210 Gigabit Network        3.05(3.05)  1533 00:008 Update not
    Connection                                                   available
03) Intel(R) I210 Gigabit Network        3.05(3.05)  1533 00:009 Update not
    Connection                                                   available

Options: Adapter Index List (comma-separated), [A]ll, e[X]it
Enter selection:a
Would you like to back up the NVM images? [Y]es/[N]o: y
Update in progress. This operation may take several minutes.
[**-.......]


Num Description                          Ver.(hex)  DevId S:B    Status
=== ================================== ============ ===== ====== ==============
01) Intel(R) Ethernet Converged         6.128(6.80)  1572 00:001 Update
    Network Adapter X710                                         successful
02) Intel(R) I210 Gigabit Network        3.05(3.05)  1533 00:008 Update not
    Connection                                                   available
03) Intel(R) I210 Gigabit Network        3.05(3.05)  1533 00:009 Update not
    Connection                                                   available

Reboot is required to complete the update process.

Tool execution completed with the following status: All operations completed successfully.
Press any key to exit.

$ sudo update-initramfs -u
update-initramfs: Generating /boot/initrd.img-4.4.0-142-generic
W: Possible missing firmware /lib/firmware/ast_dp501_fw.bin for module ast
W: mdadm: /etc/mdadm/mdadm.conf defines no arrays.

$ sudo reboot
```

##### Vilified

- Before (No Install New i40e driver & Update Firmware)

```sh
$ ethtool -i ens11f0
driver: i40e
version: 1.4.25-k
firmware-version: 5.02 0x80002248 1.1313.0
expansion-rom-version:
bus-info: 0000:01:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: yes

$ modinfo i40e
filename:       /lib/modules/4.4.0-131-generic/kernel/drivers/net/ethernet/intel/i40e/i40e.ko
version:        1.4.25-k
license:        GPL
description:    Intel(R) Ethernet Connection XL710 Network Driver
author:         Intel Corporation, <e1000-devel@lists.sourceforge.net>
srcversion:     8FEABE523F015849EA52A4B
alias:          pci:v00008086d00001588sv*sd*bc*sc*i*
alias:          pci:v00008086d00001587sv*sd*bc*sc*i*
alias:          pci:v00008086d000037D2sv*sd*bc*sc*i*
alias:          pci:v00008086d000037D1sv*sd*bc*sc*i*
alias:          pci:v00008086d000037D0sv*sd*bc*sc*i*
alias:          pci:v00008086d000037CFsv*sd*bc*sc*i*
alias:          pci:v00008086d000037CEsv*sd*bc*sc*i*
alias:          pci:v00008086d00001587sv*sd*bc*sc*i*
alias:          pci:v00008086d00001589sv*sd*bc*sc*i*
alias:          pci:v00008086d00001586sv*sd*bc*sc*i*
alias:          pci:v00008086d00001585sv*sd*bc*sc*i*
alias:          pci:v00008086d00001584sv*sd*bc*sc*i*
alias:          pci:v00008086d00001583sv*sd*bc*sc*i*
alias:          pci:v00008086d00001581sv*sd*bc*sc*i*
alias:          pci:v00008086d00001580sv*sd*bc*sc*i*
alias:          pci:v00008086d00001574sv*sd*bc*sc*i*
alias:          pci:v00008086d00001572sv*sd*bc*sc*i*
depends:        ptp,vxlan
retpoline:      Y
intree:         Y
vermagic:       4.4.0-131-generic SMP mod_unload modversions retpoline
parm:           debug:Debug level (0=none,...,16=all) (int)
```

- After

```sh
$ ethtool -i ens11f0
driver: i40e
version: 2.4.10
firmware-version: 6.80 0x80003ce6 1.1313.0
expansion-rom-version:
bus-info: 0000:01:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: yes

$ modinfo i40e
filename:       /lib/modules/4.4.0-131-generic/updates/drivers/net/ethernet/intel/i40e/i40e.ko
version:        2.4.10
license:        GPL
description:    Intel(R) 40-10 Gigabit Ethernet Connection Network Driver
author:         Intel Corporation, <e1000-devel@lists.sourceforge.net>
srcversion:     3977C21019A3C4865FF253A
alias:          pci:v00008086d0000158Bsv*sd*bc*sc*i*
alias:          pci:v00008086d0000158Asv*sd*bc*sc*i*
alias:          pci:v00008086d000037D3sv*sd*bc*sc*i*
alias:          pci:v00008086d000037D2sv*sd*bc*sc*i*
alias:          pci:v00008086d000037D1sv*sd*bc*sc*i*
alias:          pci:v00008086d000037D0sv*sd*bc*sc*i*
alias:          pci:v00008086d000037CFsv*sd*bc*sc*i*
alias:          pci:v00008086d000037CEsv*sd*bc*sc*i*
alias:          pci:v00008086d00001588sv*sd*bc*sc*i*
alias:          pci:v00008086d00001587sv*sd*bc*sc*i*
alias:          pci:v00008086d00001589sv*sd*bc*sc*i*
alias:          pci:v00008086d00001586sv*sd*bc*sc*i*
alias:          pci:v00008086d00001585sv*sd*bc*sc*i*
alias:          pci:v00008086d00001584sv*sd*bc*sc*i*
alias:          pci:v00008086d00001583sv*sd*bc*sc*i*
alias:          pci:v00008086d00001581sv*sd*bc*sc*i*
alias:          pci:v00008086d00001580sv*sd*bc*sc*i*
alias:          pci:v00008086d00001574sv*sd*bc*sc*i*
alias:          pci:v00008086d00001572sv*sd*bc*sc*i*
depends:        ptp,vxlan
retpoline:      Y
vermagic:       4.4.0-131-generic SMP mod_unload modversions retpoline
parm:           debug:Debug level (0=none,...,16=all) (int)
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
