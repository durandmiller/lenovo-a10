#!/usr/bin/env bash


# ******************  Any error is a bad error. Die immediately

set -e


# ****************** Load up configurations

SCRIPT=$0
DIR=$(dirname ${SCRIPT})/../
DIR=$(readlink -f ${DIR})

if [ ! -r ${DIR}/config ]; then
	echo "Please copy config.example to config, check it, and run this again."
	exit -1
fi;

source ${DIR}/config

# ******************  Set up defaults and locations

if [ ! -r ${DIR}/defaults ]; then
	echo "defaults is not found. Something is wrong."
	exit -1
fi;

source ${DIR}/defaults

# ******************  Check for the existence of some files

if [ ! -r ${KCONFIG} ]; then
	echo "ERROR - can't open kernel config: ${KCONFIG}";
	exit -1;
fi;

if [ ! -d ${KERNEL} ]; then
	echo "ERROR - kernel directory not found: ${KERNEL}";
	exit -1;
fi;

# ******************  Check for executables

GCC=`which ${CROSS_COMPILE}gcc`
if [ $? != 0 ]; then
	echo "Unable to locate crosscompiler: ${CROSS_COMPILE}gcc";
	exit -1;
fi;

if [ ! -x ${GCC} ]; then
	echo "Unable to execute gcc: ${CROSS_COMPILE}gcc";
	exit -1;
fi

# ******************  Ensuring the build directory

if [ ! -d ${BUILDDIR} ]; then
	mkdir -p ${BUILDDIR};
fi;


# ******************  Compile the kernel and modules

echo "Configuring and compiling the kernel and modules"

( cd ${KERNEL} && \
	cp ${KCONFIG} ${KERNEL}/.config && \
	ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} make && \
	cd - )


cp -f ${KERNEL}/arch/arm/boot/Image ${BUILDDIR}/

