#!bin/sh
cp /opt/vision_apps/setup/k3-j722s-evm.dtb /run/media/boot-mmcblk1p1/dtb/ti/k3-j722s-evm.dtb
cp /opt/vision_apps/setup/k3-j722s-evm.dtb /run/media/root-mmcblk1p2/opt/vision_apps/k3-j722s-evm.dtb
cp /opt/vision_apps/setup/k3-j722s-evm.dtb /run/media/root-mmcblk1p2/boot/dtb/ti/k3-j722s-evm.dtb
cp /opt/vision_apps/setup/k3-j722s-evm.dtb /run/media/mmcblk0p1/dtb/ti/k3-j722s-evm.dtb
cp /opt/vision_apps/setup/k3-j722s-evm.dtb /run/media/mmcblk0p2/boot/dtb/ti/k3-j722s-evm.dtb
cp /opt/vision_apps/setup/k3-j722s-evm.dtb /boot/dtb/ti/k3-j722s-evm.dtb

cp /opt/vision_apps/setup/u-boot.img /run/media/boot-mmcblk1p1/u-boot.img
cp /opt/vision_apps/setup/vx_app_rtos_linux* /run/media/boot-mmcblk1p1/
cp /opt/vision_apps/setup/uEnv.txt_nfs_auto /run/media/boot-mmcblk1p1/uEnv.txt
sync
