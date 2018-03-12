#!/bin/sh

#deleta a partição
dd if=/dev/zero of=/dev/mmcblk1 bs=1M count=1

#cria partição
sfdisk /dev/mmcblk1 < /root/sda.sfdisk

#formata partição
mkfs.ext4 -F /dev/mmcblk1p1

#escreve u-boot
dd if=/root/u-boot-sunxi-with-spl.bin of=/dev/mmcblk1 bs=1024 seek=8

#monta partição
mkdir /mnt/
mount /dev/mmcblk1p1 /mnt

#copia rootfs
cp -ax /{bin,dev,etc,lib,root,sbin,usr,var} /mnt

mkdir /mnt/{home,proc,opt,sys,tmp}

chmod 777 /mnt/tmp

#pega o ID do disco
UUID=$(blkid | grep mmcblk1p1 | cut -d' ' -f2)
#remove as aspas
UUIDC=$(echo $UUID | sed "s/\"//g")

#gera o arquivo fstab
echo "$UUID / ext4 defaults,noatime,nodiratime,commit=600,errors=remount-ro 0 1" > /mnt/etc/fstab
echo "tmpfs /tmp tmpfs defaults,nosuid 0 0" >> /mnt/etc/fstab

#copia a pasta boot
mv /root/boot_mmc /mnt/boot

#cria arquivo boot.cmd

echo '# Recompile with:' > /mnt/boot/boot.cmd
echo '# mkimage -C none -A arm -T script -d boot.cmd boot.scr' > /mnt/boot/boot.cmd

echo '# default values' >> /mnt/boot/boot.cmd
echo 'setenv kernel "zImage"' >> /mnt/boot/boot.cmd
echo 'setenv ramdisk "uInitrd"' >> /mnt/boot/boot.cmd
echo 'setenv fdtfile "sun8i-h3-nanopi-neo-core.dtb"' >> /mnt/boot/boot.cmd
echo 'setenv load_addr "0x44000000"' >> /mnt/boot/boot.cmd
echo 'setenv rootdev "/dev/mmcblk1p1"' >> /mnt/boot/boot.cmd
echo 'setenv consoleargs "console=ttyS0,115200"' >> /mnt/boot/boot.cmd
echo 'setenv uuid "'$UUIDC'"' >> /mnt/boot/boot.cmd
echo 'setenv rootfstype "ext4"' >> /mnt/boot/boot.cmd

echo 'part uuid mmc 1:1 partuuid' >> /mnt/boot/boot.cmd

echo 'load mmc 1 ${kernel_addr_r} /boot/${kernel}' >> /mnt/boot/boot.cmd
echo 'load mmc 1 ${ramdisk_addr_r} /boot/${ramdisk}' >> /mnt/boot/boot.cmd
echo 'load mmc 1 ${fdt_addr_r} /boot/${fdtfile}' >> /mnt/boot/boot.cmd
echo 'fdt addr ${fdt_addr_r}' >> /mnt/boot/boot.cmd
echo 'fdt resize 65536' >> /mnt/boot/boot.cmd

echo '# setup MAC address ' >> /mnt/boot/boot.cmd
echo 'fdt set /soc/ethernet@1c30000 local-mac-address ${mac_node}' >> /mnt/boot/boot.cmd

echo 'setenv bootargs ${consoleargs} root=${rootdev} rootfstype=${rootfstype} rw rootwait' >> /mnt/boot/boot.cmd

echo 'fsck.repair=${fsck.repair} panic=10 ${extra} fbcon=${fbcon}' >> /mnt/boot/boot.cmd

echo 'bootz ${kernel_addr_r} ${ramdisk_addr_r} ${fdt_addr_r}' >> /mnt/boot/boot.cmd

#recompila a imagem
mkimage -C none -A arm -T script -d /mnt/boot/boot.cmd /mnt/boot/boot.scr







