# Recompile with:
# mkimage -C none -A arm -T script -d boot.cmd boot.scr

# default values
setenv kernel "zImage"
setenv ramdisk "uInitrd"
setenv fdtfile "sun8i-h3-nanopi-neo-core.dtb"
setenv load_addr "0x44000000"
setenv rootdev "/dev/mmcblk1p1"
setenv consoleargs "console=ttyS0,115200"
setenv uuid "UUID=eb044601-57d2-4750-bee8-179ec75bfbe4"
setenv rootfstype "ext4"

part uuid mmc 1:1 partuuid

load mmc 1 ${kernel_addr_r} /boot/${kernel}
load mmc 1 ${ramdisk_addr_r} /boot/${ramdisk}
load mmc 1 ${fdt_addr_r} /boot/${fdtfile}
fdt addr ${fdt_addr_r}
fdt resize 65536

# setup MAC address 
fdt set /soc/ethernet@1c30000 local-mac-address ${mac_node}

setenv bootargs ${consoleargs} root=${rootdev} rootfstype=${rootfstype} rw rootwait

fsck.repair=${fsck.repair} panic=10 ${extra} fbcon=${fbcon}

bootz ${kernel_addr_r} ${ramdisk_addr_r} ${fdt_addr_r}
