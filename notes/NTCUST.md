# Deploy ENV

## Node1

ip: 10.0.0.224

### IP

```sh
$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp5s0f0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN group default qlen 1000
    link/ether b4:96:91:35:58:68 brd ff:ff:ff:ff:ff:ff
3: enp5s0f1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN group default qlen 1000
    link/ether b4:96:91:35:58:69 brd ff:ff:ff:ff:ff:ff
4: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether a0:48:1c:a0:6d:92 brd ff:ff:ff:ff:ff:ff
    inet 10.0.0.224/24 brd 10.0.0.255 scope global eno1
       valid_lft forever preferred_lft forever
    inet6 fe80::a248:1cff:fea0:6d92/64 scope link 
       valid_lft forever preferred_lft forever
5: enp5s0f2: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN group default qlen 1000
    link/ether b4:96:91:35:58:6a brd ff:ff:ff:ff:ff:ff
6: enp5s0f3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether b4:96:91:35:58:6b brd ff:ff:ff:ff:ff:ff
    inet6 fe80::b696:91ff:fe35:586b/64 scope link 
       valid_lft forever preferred_lft forever
```

### Interface Driver Module

```sh
$ ethtool -i enp5s0f0 | grep ^driver
driver: igb
$ ethtool -i enp5s0f1 | grep ^driver
driver: igb
$ ethtool -i enp5s0f2 | grep ^driver
driver: igb
$ ethtool -i enp5s0f3 | grep ^driver
driver: igb
$ ethtool -i eno1 | grep ^driver
driver: e1000e
```

### Devices Infomation

```sh
$ lspci | grep -i Ethernet
00:19.0 Ethernet controller: Intel Corporation Ethernet Connection I217-LM (rev 05)
05:00.0 Ethernet controller: Intel Corporation I350 Gigabit Network Connection (rev 01)
05:00.1 Ethernet controller: Intel Corporation I350 Gigabit Network Connection (rev 01)
05:00.2 Ethernet controller: Intel Corporation I350 Gigabit Network Connection (rev 01)
05:00.3 Ethernet controller: Intel Corporation I350 Gigabit Network Connection (rev 01)

$ sudo lshw -class network -businfo
Bus info          Device      Class          Description
========================================================
pci@0000:00:19.0  eno1        network        Ethernet Connection I217-LM
pci@0000:05:00.0  enp5s0f0    network        I350 Gigabit Network Connection
pci@0000:05:00.1  enp5s0f1    network        I350 Gigabit Network Connection
pci@0000:05:00.2  enp5s0f2    network        I350 Gigabit Network Connection
pci@0000:05:00.3  enp5s0f3    network        I350 Gigabit Network Connection
```

### Hugepages

```sh
$ cat /proc/meminfo | grep Huge
AnonHugePages:         0 kB
HugePages_Total:       4
HugePages_Free:        4
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:    1048576 kB
```

### IOMMU

```sh
$  dmesg | grep -e IOMMU
[    0.000000] DMAR: IOMMU enabled
[    0.035934] DMAR-IR: IOAPIC id 2 under DRHD base  0xfed90000 IOMMU 0
```

### SR-IOV VF numbers

```sh
$ head -n 1 /sys/class/net/*/device/sriov_totalvfs
==> /sys/class/net/enp5s0f0/device/sriov_totalvfs <==
7

==> /sys/class/net/enp5s0f1/device/sriov_totalvfs <==
7

==> /sys/class/net/enp5s0f2/device/sriov_totalvfs <==
7

==> /sys/class/net/enp5s0f3/device/sriov_totalvfs <==
7
```

## Node2

ip: 10.0.0.225

### IP

```sh
$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp5s0f0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN group default qlen 1000
    link/ether b4:96:91:28:86:64 brd ff:ff:ff:ff:ff:ff
3: enp5s0f1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN group default qlen 1000
    link/ether b4:96:91:28:86:65 brd ff:ff:ff:ff:ff:ff
4: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether a0:48:1c:a6:17:84 brd ff:ff:ff:ff:ff:ff
    inet 10.0.0.225/24 brd 10.0.0.255 scope global eno1
       valid_lft forever preferred_lft forever
    inet6 fe80::a248:1cff:fea6:1784/64 scope link 
       valid_lft forever preferred_lft forever
5: enp5s0f2: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN group default qlen 1000
    link/ether b4:96:91:28:86:66 brd ff:ff:ff:ff:ff:ff
6: enp5s0f3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether b4:96:91:28:86:67 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::b696:91ff:fe28:8667/64 scope link 
       valid_lft forever preferred_lft forever
```

### Interface Driver Module

```sh
$ ethtool -i enp5s0f0 | grep ^driver
driver: igb
$ ethtool -i enp5s0f1 | grep ^driver
driver: igb
$ ethtool -i enp5s0f2 | grep ^driver
driver: igb
$ ethtool -i enp5s0f3 | grep ^driver
driver: igb
$ ethtool -i eno1 | grep ^driver
driver: e1000e
```

### Devices Infomation

```sh
$ lspci | grep -i Ethernet
00:19.0 Ethernet controller: Intel Corporation Ethernet Connection I217-LM (rev 05)
05:00.0 Ethernet controller: Intel Corporation I350 Gigabit Network Connection (rev 01)
05:00.1 Ethernet controller: Intel Corporation I350 Gigabit Network Connection (rev 01)
05:00.2 Ethernet controller: Intel Corporation I350 Gigabit Network Connection (rev 01)
05:00.3 Ethernet controller: Intel Corporation I350 Gigabit Network Connection (rev 01)

$ sudo lshw -class network -businfo
Bus info          Device      Class          Description
========================================================
pci@0000:00:19.0  eno1        network        Ethernet Connection I217-LM
pci@0000:05:00.0  enp5s0f0    network        I350 Gigabit Network Connection
pci@0000:05:00.1  enp5s0f1    network        I350 Gigabit Network Connection
pci@0000:05:00.2  enp5s0f2    network        I350 Gigabit Network Connection
pci@0000:05:00.3  enp5s0f3    network        I350 Gigabit Network Connection
```

### Hugepages

```sh
$ cat /proc/meminfo | grep Huge
AnonHugePages:         0 kB
HugePages_Total:       4
HugePages_Free:        4
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:    1048576 kB
```

### IOMMU

```sh
$ dmesg | grep -e IOMMU
[    0.000000] DMAR: IOMMU enabled
[    0.041601] DMAR-IR: IOAPIC id 2 under DRHD base  0xfed90000 IOMMU 0
```

### SR-IOV VF numbers

```sh
$ head -n 1 /sys/class/net/*/device/sriov_totalvfs
==> /sys/class/net/enp5s0f0/device/sriov_totalvfs <==
7

==> /sys/class/net/enp5s0f1/device/sriov_totalvfs <==
7

==> /sys/class/net/enp5s0f2/device/sriov_totalvfs <==
7

==> /sys/class/net/enp5s0f3/device/sriov_totalvfs <==
7
```

## Node3

ip: 10.0.0.226

### IP
```sh
$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp2s0f0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN group default qlen 1000
    link/ether b4:96:91:35:58:98 brd ff:ff:ff:ff:ff:ff
3: enp2s0f1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN group default qlen 1000
    link/ether b4:96:91:35:58:99 brd ff:ff:ff:ff:ff:ff
4: enp2s0f2: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN group default qlen 1000
    link/ether b4:96:91:35:58:9a brd ff:ff:ff:ff:ff:ff
5: enp2s0f3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether b4:96:91:35:58:9b brd ff:ff:ff:ff:ff:ff
    inet6 fe80::b696:91ff:fe35:589b/64 scope link 
       valid_lft forever preferred_lft forever
6: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 90:fb:a6:86:56:2a brd ff:ff:ff:ff:ff:ff
    inet 10.0.0.226/24 brd 10.0.0.255 scope global eno1
       valid_lft forever preferred_lft forever
    inet6 fe80::92fb:a6ff:fe86:562a/64 scope link 
       valid_lft forever preferred_lft forever
7: eno2: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN group default qlen 1000
    link/ether 90:fb:a6:86:56:2b brd ff:ff:ff:ff:ff:ff
8: rename8: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN group default qlen 1000
    link/ether 90:fb:a6:86:56:2c brd ff:ff:ff:ff:ff:ff
9: rename9: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN group default qlen 1000
    link/ether 90:fb:a6:86:56:2d brd ff:ff:ff:ff:ff:ff
```

### Interface Driver Module

```sh
$ ethtool -i enp2s0f0 | grep ^driver
driver: igb
$ ethtool -i enp2s0f1 | grep ^driver
driver: igb
$ ethtool -i enp2s0f2 | grep ^driver
driver: igb
$ ethtool -i enp2s0f3 | grep ^driver
driver: igb
$ ethtool -i rename8 | grep ^driver
driver: ixgbe
$ ethtool -i rename9 | grep ^driver
driver: ixgbe
```

### Devices Infomation

```sh
$ lspci | grep -i Ethernet
02:00.0 Ethernet controller: Intel Corporation I350 Gigabit Network Connection (rev 01)
02:00.1 Ethernet controller: Intel Corporation I350 Gigabit Network Connection (rev 01)
02:00.2 Ethernet controller: Intel Corporation I350 Gigabit Network Connection (rev 01)
02:00.3 Ethernet controller: Intel Corporation I350 Gigabit Network Connection (rev 01)
05:00.0 Ethernet controller: Intel Corporation 82599ES 10-Gigabit SFI/SFP+ Network Connection (rev 01)
05:00.1 Ethernet controller: Intel Corporation 82599ES 10-Gigabit SFI/SFP+ Network Connection (rev 01)
08:00.0 Ethernet controller: Intel Corporation I350 Gigabit Network Connection (rev 01)
08:00.1 Ethernet controller: Intel Corporation I350 Gigabit Network Connection (rev 01)

$ sudo lshw -class network -businfo
Bus info          Device     Class          Description
=======================================================
pci@0000:02:00.0  enp2s0f0   network        I350 Gigabit Network Connection
pci@0000:02:00.1  enp2s0f1   network        I350 Gigabit Network Connection
pci@0000:02:00.2  enp2s0f2   network        I350 Gigabit Network Connection
pci@0000:02:00.3  enp2s0f3   network        I350 Gigabit Network Connection
pci@0000:05:00.0  rename8    network        82599ES 10-Gigabit SFI/SFP+ Network Connection
pci@0000:05:00.1  rename9    network        82599ES 10-Gigabit SFI/SFP+ Network Connection
pci@0000:08:00.0  eno1       network        I350 Gigabit Network Connection
pci@0000:08:00.1  eno2       network        I350 Gigabit Network Connection
```

### Hugepages

```sh
$ cat /proc/meminfo | grep Huge
AnonHugePages:         0 kB
HugePages_Total:       4
HugePages_Free:        4
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:    1048576 kB
```

### IOMMU

```sh
$ dmesg | grep -e IOMMU
[    0.000000] DMAR: IOMMU enabled
[    0.117836] DMAR-IR: IOAPIC id 3 under DRHD base  0xfbffe000 IOMMU 0
[    0.117933] DMAR-IR: IOAPIC id 0 under DRHD base  0xdfffc000 IOMMU 1
[    0.118029] DMAR-IR: IOAPIC id 2 under DRHD base  0xdfffc000 IOMMU 1
```

### SR-IOV VF numbers

```sh
$ head -n 1 /sys/class/net/*/device/sriov_totalvfs
==> /sys/class/net/eno1/device/sriov_totalvfs <==
7

==> /sys/class/net/eno2/device/sriov_totalvfs <==
7

==> /sys/class/net/enp2s0f0/device/sriov_totalvfs <==
7

==> /sys/class/net/enp2s0f1/device/sriov_totalvfs <==
7

==> /sys/class/net/enp2s0f2/device/sriov_totalvfs <==
7

==> /sys/class/net/enp2s0f3/device/sriov_totalvfs <==
7

==> /sys/class/net/rename8/device/sriov_totalvfs <==
63

==> /sys/class/net/rename9/device/sriov_totalvfs <==
63
```
