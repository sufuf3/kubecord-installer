# Deploy ENV

## Node1

ip: 140.113.X.5

### IP

```sh
$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
4: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether a8:1e:84:a1:da:0c brd ff:ff:ff:ff:ff:ff
    inet 140.113.X.5/25 brd 140.113.X.127 scope global eno1
       valid_lft forever preferred_lft forever
    inet6 fe80::aa1e:84ff:fea1:da0c/64 scope link
       valid_lft forever preferred_lft forever
7: eno2: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN group default qlen 1000
    link/ether a8:1e:84:a1:da:0d brd ff:ff:ff:ff:ff:ff
8: enp4s0f0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN group default qlen 1000
    link/ether a8:1e:84:a1:dc:71 brd ff:ff:ff:ff:ff:ff
9: enp4s0f1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN group default qlen 1000
    link/ether a8:1e:84:a1:dc:72 brd ff:ff:ff:ff:ff:ff
14: ens6f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq portid 3cfdfebafa98 state UP group default qlen 1000
    link/ether 3c:fd:fe:ba:fa:98 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::3efd:feff:feba:fa98/64 scope link
       valid_lft forever preferred_lft forever
15: ens6f1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq portid 3cfdfebafa99 state UP group default qlen 1000
    link/ether 3c:fd:fe:ba:fa:99 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::3efd:feff:feba:fa99/64 scope link
       valid_lft forever preferred_lft forever
16: ens6f2: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq portid 3cfdfebafa9a state DOWN group default qlen 1000
    link/ether 3c:fd:fe:ba:fa:9a brd ff:ff:ff:ff:ff:ff
17: ens6f3: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq portid 3cfdfebafa9b state DOWN group default qlen 1000
    link/ether 3c:fd:fe:ba:fa:9b brd ff:ff:ff:ff:ff:ff
```

### Interface Driver Module

```sh
$ ethtool -i ens6f0 | grep ^driver
driver: i40e
$ ethtool -i ens6f1 | grep ^driver
driver: i40e
$ ethtool -i ens6f2 | grep ^driver
driver: i40e
$ ethtool -i ens6f3 | grep ^driver
driver: i40e
$ ethtool -i enp4s0f0 | grep ^driver
driver: ixgbe
$ ethtool -i enp4s0f1 | grep ^driver
driver: ixgbe
$ ethtool -i eno1 | grep ^driver
driver: ixgbe
$ ethtool -i eno2 | grep ^driver
driver: ixgbe
```

### Devices Infomation

```sh
$ lspci | grep -i Ethernet
01:00.0 Ethernet controller: Intel Corporation Ethernet Controller 10-Gigabit X540-AT2 (rev 01)
01:00.1 Ethernet controller: Intel Corporation Ethernet Controller 10-Gigabit X540-AT2 (rev 01)
04:00.0 Ethernet controller: Intel Corporation Ethernet Controller 10-Gigabit X540-AT2 (rev 01)
04:00.1 Ethernet controller: Intel Corporation Ethernet Controller 10-Gigabit X540-AT2 (rev 01)
83:00.0 Ethernet controller: Intel Corporation Ethernet Controller X710 for 10GbE SFP+ (rev 01)
83:00.1 Ethernet controller: Intel Corporation Ethernet Controller X710 for 10GbE SFP+ (rev 01)
83:00.2 Ethernet controller: Intel Corporation Ethernet Controller X710 for 10GbE SFP+ (rev 01)
83:00.3 Ethernet controller: Intel Corporation Ethernet Controller X710 for 10GbE SFP+ (rev 01)

$ sudo lshw -class network -businfo
Bus info          Device      Class          Description
========================================================
pci@0000:01:00.0  eno1        network        Ethernet Controller 10-Gigabit X540-AT2
pci@0000:01:00.1  eno2        network        Ethernet Controller 10-Gigabit X540-AT2
pci@0000:04:00.0  enp4s0f0    network        Ethernet Controller 10-Gigabit X540-AT2
pci@0000:04:00.1  enp4s0f1    network        Ethernet Controller 10-Gigabit X540-AT2
pci@0000:83:00.0  ens6f0      network        Ethernet Controller X710 for 10GbE SFP+
pci@0000:83:00.1  ens6f1      network        Ethernet Controller X710 for 10GbE SFP+
pci@0000:83:00.2  ens6f2      network        Ethernet Controller X710 for 10GbE SFP+
pci@0000:83:00.3  ens6f3      network        Ethernet Controller X710 for 10GbE SFP+
```

### Hugepages

```sh
$ cat /proc/meminfo | grep Huge
AnonHugePages:         0 kB
ShmemHugePages:        0 kB
HugePages_Total:       8
HugePages_Free:        8
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
$ head -n 1 /sys/class/net/*/device/sriov_totalvfs
==> /sys/class/net/eno1/device/sriov_totalvfs <==
63

==> /sys/class/net/eno2/device/sriov_totalvfs <==
63

==> /sys/class/net/enp4s0f0/device/sriov_totalvfs <==
63

==> /sys/class/net/enp4s0f1/device/sriov_totalvfs <==
63

==> /sys/class/net/ens6f0/device/sriov_totalvfs <==
32

==> /sys/class/net/ens6f1/device/sriov_totalvfs <==
32

==> /sys/class/net/ens6f2/device/sriov_totalvfs <==
32

==> /sys/class/net/ens6f3/device/sriov_totalvfs <==
32
```

## Node2

ip: 140.113.X.6

### IP

```sh
$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: ens6f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq portid 3cfdfebaf988 state UP group default qlen 1000
    link/ether 3c:fd:fe:ba:f9:88 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::3efd:feff:feba:f988/64 scope link
       valid_lft forever preferred_lft forever
3: ens6f1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq portid 3cfdfebaf989 state UP group default qlen 1000
    link/ether 3c:fd:fe:ba:f9:89 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::3efd:feff:feba:f989/64 scope link
       valid_lft forever preferred_lft forever
4: ens6f2: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq portid 3cfdfebaf98a state DOWN group default qlen 1000
    link/ether 3c:fd:fe:ba:f9:8a brd ff:ff:ff:ff:ff:ff
5: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether a8:1e:84:a1:d9:a6 brd ff:ff:ff:ff:ff:ff
    inet 140.113.X.6/25 brd 140.113.X.127 scope global eno1
       valid_lft forever preferred_lft forever
    inet6 fe80::aa1e:84ff:fea1:d9a6/64 scope link
       valid_lft forever preferred_lft forever
6: ens6f3: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq portid 3cfdfebaf98b state DOWN group default qlen 1000
    link/ether 3c:fd:fe:ba:f9:8b brd ff:ff:ff:ff:ff:ff
7: eno2: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN group default qlen 1000
    link/ether a8:1e:84:a1:d9:a7 brd ff:ff:ff:ff:ff:ff
8: enp4s0f0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN group default qlen 1000
    link/ether a8:1e:84:a1:dc:6d brd ff:ff:ff:ff:ff:ff
9: enp4s0f1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN group default qlen 1000
    link/ether a8:1e:84:a1:dc:6e brd ff:ff:ff:ff:ff:ff
```

### Interface Driver Module

```sh
$ ethtool -i ens6f0 | grep ^driver
driver: i40e
$ ethtool -i ens6f1 | grep ^driver
driver: i40e
$ ethtool -i ens6f2 | grep ^driver
driver: i40e
$ ethtool -i ens6f3 | grep ^driver
driver: i40e
$ ethtool -i enp4s0f0 | grep ^driver
driver: ixgbe
$ ethtool -i enp4s0f1 | grep ^driver
driver: ixgbe
$ ethtool -i eno1 | grep ^driver
driver: ixgbe
$ ethtool -i eno2 | grep ^driver
driver: ixgbe
```

### Devices Infomation

```sh
$ lspci | grep -i Ethernet
01:00.0 Ethernet controller: Intel Corporation Ethernet Controller 10-Gigabit X540-AT2 (rev 01)
01:00.1 Ethernet controller: Intel Corporation Ethernet Controller 10-Gigabit X540-AT2 (rev 01)
04:00.0 Ethernet controller: Intel Corporation Ethernet Controller 10-Gigabit X540-AT2 (rev 01)
04:00.1 Ethernet controller: Intel Corporation Ethernet Controller 10-Gigabit X540-AT2 (rev 01)
83:00.0 Ethernet controller: Intel Corporation Ethernet Controller X710 for 10GbE SFP+ (rev 01)
83:00.1 Ethernet controller: Intel Corporation Ethernet Controller X710 for 10GbE SFP+ (rev 01)
83:00.2 Ethernet controller: Intel Corporation Ethernet Controller X710 for 10GbE SFP+ (rev 01)
83:00.3 Ethernet controller: Intel Corporation Ethernet Controller X710 for 10GbE SFP+ (rev 01)

$ sudo lshw -class network -businfo
Bus info          Device     Class          Description
=======================================================
pci@0000:01:00.0  eno1       network        Ethernet Controller 10-Gigabit X540-AT2
pci@0000:01:00.1  eno2       network        Ethernet Controller 10-Gigabit X540-AT2
pci@0000:04:00.0  enp4s0f0   network        Ethernet Controller 10-Gigabit X540-AT2
pci@0000:04:00.1  enp4s0f1   network        Ethernet Controller 10-Gigabit X540-AT2
pci@0000:83:00.0  ens6f0     network        Ethernet Controller X710 for 10GbE SFP+
pci@0000:83:00.1  ens6f1     network        Ethernet Controller X710 for 10GbE SFP+
pci@0000:83:00.2  ens6f2     network        Ethernet Controller X710 for 10GbE SFP+
pci@0000:83:00.3  ens6f3     network        Ethernet Controller X710 for 10GbE SFP+
```

### Hugepages

```sh
$ cat /proc/meminfo | grep Huge
AnonHugePages:         0 kB
ShmemHugePages:        0 kB
HugePages_Total:       8
HugePages_Free:        8
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
$ head -n 1 /sys/class/net/*/device/sriov_totalvfs
==> /sys/class/net/eno1/device/sriov_totalvfs <==
63

==> /sys/class/net/eno2/device/sriov_totalvfs <==
63

==> /sys/class/net/enp4s0f0/device/sriov_totalvfs <==
63

==> /sys/class/net/enp4s0f1/device/sriov_totalvfs <==
63

==> /sys/class/net/ens6f0/device/sriov_totalvfs <==
32

==> /sys/class/net/ens6f1/device/sriov_totalvfs <==
32

==> /sys/class/net/ens6f2/device/sriov_totalvfs <==
32

==> /sys/class/net/ens6f3/device/sriov_totalvfs <==
32
```

## Setup SR-IOV VF

### Node1 & Node2

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
echo 30 | sudo tee -a /sys/class/net/ens6f0/device/sriov_numvfs
echo 30 | sudo tee -a /sys/class/net/ens6f1/device/sriov_numvfs
```

```sh
$ head -n 1 /sys/class/net/*/device/sriov_numvfs
==> /sys/class/net/eno1/device/sriov_numvfs <==
0

==> /sys/class/net/eno2/device/sriov_numvfs <==
0

==> /sys/class/net/enp4s0f0/device/sriov_numvfs <==
0

==> /sys/class/net/enp4s0f1/device/sriov_numvfs <==
0

==> /sys/class/net/ens6f0/device/sriov_numvfs <==
30

==> /sys/class/net/ens6f1/device/sriov_numvfs <==
30

==> /sys/class/net/ens6f2/device/sriov_numvfs <==
0

==> /sys/class/net/ens6f3/device/sriov_numvfs <==
0
```

