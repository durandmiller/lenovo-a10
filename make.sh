#!/usr/bin/env bash


set -e


KEY=7C4E0304550509072D2C7B38170D1711

SCRIPT=$0
DIR=$(dirname ${SCRIPT})
DIR=$(readlink -f ${DIR})
BUILDDIR=${DIR}/build
INITRAMFS=${BUILDDIR}/initramfs

if [ ! -r ${DIR}/config ]; then
	echo "Please copy config.example to config, check it, and run this again."
	exit -1
fi;

source ${DIR}/config


KCONFIG=${DIR}/kernels/kconfigs/${LINUX}
KERNEL=${DIR}/kernels/${LINUX}


RKFLASHTOOL=${DIR}/submodules/rkflashtool/rkflashtool
RKCRC=${DIR}/submodules/rkflashtool/rkcrc
UNPACK=${DIR}/submodules/rk3066-rom-scripts/unpack_loader.pl
MKBOOTIMG=${DIR}/submodules/rockchip-mkbootimg/mkbootimg


git submodule init

rm -rf ${INITRAMFS}/
mkdir -p ${BUILDDIR}
mkdir -p ${INITRAMFS}/



# Compile rkflashtool
( cd ${DIR}/submodules/rkflashtool && \
	make && \
	cd - )

# Compile rockchip-mkbootimg
( cd ${DIR}/submodules/rockchip-mkbootimg && \
	make && \
	cd - )


# Compile uboot
#( cd ${DIR}/submodules/u-boot-rockchip && \
#	git checkout u-boot-rk3188-sdcard && \
#	ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} make rk30xx_config && \
#	ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} make rk30xx && \
#	cd - )

#cp -f ${DIR}/submodules/u-boot-rockchip/RK3188Loader_uboot.bin ${BUILDDIR}/RK3188Loader.bin
#cp -f ${DIR}/submodules/u-boot-rockchip/u-boot.bin ${BUILDDIR}/u-boot.bin
#${RKCRC} -k ${BUILDDIR}/u-boot.bin ${BUILDDIR}/kernel.img
#${RKCRC} -k ${BUILDDIR}/u-boot.bin ${BUILDDIR}/boot.img

echo "Configuring and compiling the kernel and modules"

( cd ${KERNEL} && \
	cp ${KCONFIG} ${KERNEL}/.config && \
	ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} make && \
	ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} make modules && \
	ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} make modules_install INSTALL_MOD_PATH=${INITRAMFS} && \
	cd - )


cp -f ${KERNEL}/arch/arm/boot/Image ${BUILDDIR}/


# Creating the initramfs

(
	cp -rf ${DIR}/initramfs/* ${INITRAMFS}/
	cd ${INITRAMFS}
	find . | cpio -H newc -o > ${BUILDDIR}/initramfs.cpio
	cat ${BUILDDIR}/initramfs.cpio | gzip -9 > ${BUILDDIR}/initramfs.igz
	cd -
)


cp -f ${DIR}/parts/unknown.1 ${BUILDDIR}/unknown.1
cp -f ${DIR}/parts/unknown.2 ${BUILDDIR}/unknown.2


${RKCRC} -p ${DIR}/parts/parameters ${BUILDDIR}/parameters.img
#${RKCRC} -k ${BUILDDIR}/initramfs.igz ${BUILDDIR}/initramfs.img
#${RKCRC} -k ${BUILDDIR}/Image ${BUILDDIR}/kernel.img


openssl rc4 -K ${KEY} < ${DIR}/parts/sd_header.1 > ${BUILDDIR}/sd_header.1.rc4
openssl rc4 -K ${KEY} < ${DIR}/parts/sd_header.2 > ${BUILDDIR}/sd_header.2.rc4
openssl rc4 -K ${KEY} < ${DIR}/parts/FlashBoot.bin > ${BUILDDIR}/FlashBoot.bin.rc4
openssl rc4 -K ${KEY} < ${DIR}/parts/FlashData.bin > ${BUILDDIR}/FlashData.bin.rc4


${MKBOOTIMG} \
	--kernel ${BUILDDIR}/Image \
	--ramdisk ${BUILDDIR}/initramfs.igz \
	-o ${BUILDDIR}/boot.img





