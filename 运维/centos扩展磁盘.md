# centos 扩展磁盘分区

* 环境：vmware 
* 系统：centos 7.9

## 步骤1.关机状态下在设置-硬盘-扩展-选择硬盘大小

## 步骤2. 进入系统内部执行命令扩展磁盘大小
```sh 
fdisk /dev/sda
Welcome to fdisk (util-linux 2.23.2).

Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.


Command (m for help): p

Disk /dev/sda: 53.7 GB, 53687091200 bytes, 104857600 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x000b0183

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *        2048     2099199     1048576   83  Linux
/dev/sda2         2099200    41943039    19921920   8e  Linux LVM
/dev/sda3        41943040   104857599    31457280   8e  Linux LVM

Command (m for help): n
Partition type:
   p   primary (3 primary, 0 extended, 1 free)
   e   extended
Select (default e): p
Selected partition 4
No free sectors available

Command (m for help): t
Partition number (1-3, default 3): 3
Hex code (type L to list all codes): 8e
Changed type of partition 'Linux LVM' to 'Linux LVM'

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
```
