# Recompile with:
# mkimage -C none -A arm -T script -d boot.cmd boot.scr

# default values
setenv kernel "zImage"
setenv ramdisk "uInitrd"
setenv fdtfile "core.dtb"
setenv uuid "UUID=7ac33e6e-fa92-4fd2-bb7c-bde01b119803"

part uuid mmc 0:1 partuuid

load mmc 0 ${kernel_addr_r} /boot/${kernel}
load mmc 0 ${ramdisk_addr_r} /boot/${ramdisk}
load mmc 0 ${fdt_addr_r} /boot/${fdtfile}
fdt addr ${fdt_addr_r}
fdt resize 65536

# setup MAC address 
fdt set /soc/ethernet@1c30000 local-mac-address ${mac_node}

setenv bootargs console=ttyS0,115200 earlyprintk root=/dev/mmcblk0p1 rootfstype=ext4 rw rootwait


bootz ${kernel_addr_r} ${ramdisk_addr_r} ${fdt_addr_r}
