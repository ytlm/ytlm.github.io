---
title: arch linux 初次安装成功
tags:
  - null
categories:
  - null
date: 2018-06-28 16:59:34
---

之前一直对archlinux有很大的兴趣，期间也去尝试去安装，不过全部都失败了，最近又有时间，终于安装完成，并且安装了gnome桌面。感觉用的时候是非常好的。everything is simple。首先说一下现在装好，感觉最难的就是磁盘分区和格式化，选择什么样的分区方法，怎样分区。

<!-- more -->

### 准备
首先要到官网上下在[iso](https://www.archlinux.org/download/)，做一个u盘启动盘，或者软盘，或者用virtualbox安装。
> linux系统可以直接用**dd**，windows系统可以用**ultraiso**

#### 确认引导方式
用命令`ls /sys/firmware/efi/efivars`，[详细情况看这里](https://wiki.archlinux.org/index.php/GRUB)
* `ls: cannot access '/sys/firmware/efi/efivars': No such file or directory` 这样表示是BIOS引导方式
* ![](https://ws1.sinaimg.cn/large/c11fed42gy1fsqorm8bw7j20me0j0ab0.jpg)如果显示的是这样表示是UEFI引导方式
> 我这里就是这样的，为UEFI引导方式启动的，一下全部按照这种方式进行操作的。

#### 分区并格式化
分区用的是fdisk，当然还有其它的工具分区，基本上都是大同小异的
+ [1] 首先用`fdisk -l`查看磁盘情况，这里我只有一块磁盘，所以显示的是`/dev/sda`还有此块磁盘相关的一些信息如下：![](https://ws1.sinaimg.cn/large/c11fed42gy1fsqp2v1xpyj20e004ydfq.jpg)

+ [2] 我这里分区是按照`/`，`/boot` , `/home`, `swap`这四个分区
> 大小 `/` 10G ， `/home` 5G ， `/boot` 1G ， `swap` 4G
> 类型  `/` linux filesystem ， `/home` linux filesystem ，  `/boot` EFI ，  `swap` linux swap

+  [3] 然后`fdisk /dev/sda`，开始分区，[详细情况看这里](https://wiki.archlinux.org/index.php/Fdisk)
    - (3.1) 首先输入 `g` create a new empty GPT partition table
        * ![](https://ws1.sinaimg.cn/large/c11fed42gy1fsqpc1ikvsj20gx01gq2p.jpg)
    - (3.2) 创建分区，详细如下图，分别创建4个分区， 输入`w`保存
        * ![](https://ws1.sinaimg.cn/large/c11fed42gy1fsqpk87oylj20io02z0sk.jpg)
        * 最后分区结果如下: 其中 `/dev/sda1`代表`/`，`/dev/sda2`代表`/home`，`/dev/sda3`代表`/boot`，`/dev/sda4`代表`swap`
        * ![](https://ws1.sinaimg.cn/large/c11fed42gy1fsqple6avrj20eg069jrc.jpg)
    - (3.3) 修改分区类型，`/dev/sda1`和`/dev/sda2`不变，默认就好，`/dev/sda3`改成`UFI`，`/dev/sda4`改成`linux swap`
        * 输入 `t`； 选择需要修改类型的分区编号； 输入`L`查看所有分区类型；选择需要的类型的编号； 确认； 输入`w`保存。
        * ![](https://ws1.sinaimg.cn/large/c11fed42gy1fsqpwlcfj9j20er064glk.jpg)
+ [4] 格式化分区
```bash
mkfs.ext4 /dev/sda1           # /     格式化为 ext4
mkfs.ext4 /dev/sda2           # /home 格式化为 ext4

mkfs.fat /dev/sda3            # /boot 格式化为 EFI format

mkswap /dev/sda4              # 创建交换分区
swapon /dev/sda4              # 启用交换分区
```
+ [5] 挂载分区
```bash
mount /dev/sda1 /mnt                              # `/`分区挂载到`/mnt`
mkdir /mnt/boot && mount /dev/sda3 /mnt/boot      # `/boot`分区挂载到`/mnt/boot`
mkdir /mnt/home mount /dev/sda2 /mnt/home         # `/home`分区挂载到`/mnt/home`
```

####  安装基础系统
```bash
vim /etc/pacman.d/mirrorlist          # 修改源镜像，一般是不用动的，我这里就是默认的

dhcpcd                                # 检查网络，我这里没有动，网络自动已经连接好了
ping www.baidu.com                    # 检查是否可用

pacstrap -i /mnt base base-devel      # 安装基础系统，这个可能要花费一些时间，和网速有关

genfstab -U /mnt >> /mnt/etc/fstab    # 生fstab文件
cat /mnt/etc/fstab                    # 查看上一部的fstab是否生效，这里可以看到，每一个分区的情况

```

### 配置系统
```bash
arch-chroot /mnt                                          # 进入系统


ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime   # 修改时区
hwclock --systohc                                         # 同步时间到硬件

vi /etc/locale.gen                                        # 设置语言
# 我这里将这三个取消注释，这个需要根据自己的情况进行更改
en_US.UTF-8 UTF-8
zh_CN.UTF-8 UTF-8
locale-gen                                                 # 使刚才的修改生效


echo 'LANG=en_US.UTF-8' > /etc/locale.conf
# 设置默认系统语言，建议设置成英文，中文的话可能会出现意想不到的问题，哈哈

设置主机名称
echo 'myhostname' > /etc/hostname

修改hosts
/etc/hosts
127.0.0.1   localhost
::1     localhost
127.0.1.1   myhostname.localdomain  myhostname

为root用户设置密码
passwd

设置dhcp自启动
systemctl enable dhcpcd
```

#### 启动项
```bash
这里都是按照 UEFI 这种引导方式进行设置的
pacman -S dosfstools grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
# /boot 这里保证是boot挂在分区的目录
grub-mkconfig -o /boot/grub/grub.cfg
```

#### 用户
```bash
useradd -m -G wheel `username`       # 创建`username`并添加到wheel用户组
passwd `username`                    # 为`username`设置密码
```

#### sudo
```bash
pacman -S sudo vim                   # 安装sudo包
visudo                               # 配置sudo
# 将这里取消注释，那以后非root用户，就可以用sudo的方式执行root命令
%wheel ALL=(ALL)ALL
```

### 重启
```bash
首先退出chroot环境，用`exit`命令或者直接使用`Ctrl+d`快捷键
reboot
```

* 配置virtualbox，因为我这里是用virtualbox安装的archlinxu，在第一次重启系统的时候，会进入EFI shell，并没有进入系统，这里要修改如下：
```bash
fs0:
edit startup.nsh
\EFI\grub\grubx64.efi
reset
```

* 配置安装gnome
```bash
sudo pacman -S xf86-video-intel                  # intel显卡驱动,如果是其它的需要安装对应的驱动
sudo pacman -S xorg
sudo pacman -S gnome gnome-extra gnome-tweak-tool
sudo systemctl enable gdm
```

* 简单配置gnome安装常用软件
编辑 /etc/pacman.conf 文件，在文件末加入（源可以替换为更适合自己的）
```bash
[archlinuxcn]
SigLevel = Optional TrustedOnly
Server = http://mirrors.163.com/archlinux-cn/$arch
```
```bash
pacman -Syy && pacman -Sy archlinuxcn-keyring
pacman -S yaourt fakeroot

yaourt -S google-chrome wireshark-gtk vlc ffmpeg vim sublime-text-deve tcpdump
yaourt -S fcix fcix-configtool screenfetch
```
* 最后放一张图，oh yeah!
![](https://ws1.sinaimg.cn/large/c11fed42gy1fsqzpcluv6j20k308g3zg.jpg)

### 后记
感觉这个系统真的很适合我啊，决定以后开发环境都在这上面了，哈哈
### 参考连接
> https://wiki.archlinux.org/index.php/Installation_guide
> https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Disks/zh-cn
> https://wiki.archlinux.org/index.php/GNOME
> https://blog.tse.moe/archlinuxan-zhuang-zhuo-mian-he-chang-yong-ruan-jian/

---

*** 如有疑问欢迎批评指正，谢谢！ ***
