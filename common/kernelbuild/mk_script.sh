#!/bin/bash
#
#  author: xindong.xu@amlogic.com
#  2020.04.15

function clean() {
	echo "Clean up"
	cd ${MAIN_FOLDER}
	rm -rf out/android*
	return
}

function build_deadpool() {
	echo "------device/askey/deadppol/build.config.meson.${ARCH}.deadpool-----"
	cd ${MAIN_FOLDER}
	export BUILD_CONFIG=device/askey/deadpool/build.config.meson.${ARCH}.deadpool

	. ${MAIN_FOLDER}/${BUILD_CONFIG}
	export $(sed -n -e 's/\([^=]\)=.*/\1/p' ${MAIN_FOLDER}/${BUILD_CONFIG})
	if [ $CONFIG_AB_UPDATE ]; then
		echo "=====ab update mode====="
		for aDts in ${KERNEL_DEVICETREE}; do
			sed -i 's/^#include \"partition_.*/#include "partition_mbox_normal_dynamic_ab.dtsi"/' ${KERNEL_DIR}/arch/${ARCH}/boot/dts/amlogic/$aDts.dts;
		done
	else
		echo "=====normal mode====="
		for aDts in ${KERNEL_DEVICETREE}; do
			sed -i 's/^#include \"partition_.*/#include "partition_mbox_dynamic_deadpool.dtsi"/' ${KERNEL_DIR}/arch/${ARCH}/boot/dts/amlogic/$aDts.dts;
		done
	fi

	cd ${MAIN_FOLDER}
	./device/khadas/common/kernelbuild/build_kernel_4.9.sh
}

function build_boreal() {
	echo "------device/google/boreal/build.config.meson.${ARCH}.trunk-----"
	cd ${MAIN_FOLDER}
	export BUILD_CONFIG=device/google/boreal/build.config.meson.${ARCH}.trunk
	export TARGET_BUILD_KERNEL_4_9=false
	. ${MAIN_FOLDER}/${BUILD_CONFIG}
	export $(sed -n -e 's/\([^=]\)=.*/\1/p' ${MAIN_FOLDER}/${BUILD_CONFIG})

	if [ $CONFIG_KERNEL_DDR_1G ]; then
		export KERNEL_DEVICETREE=${KERNEL_DEVICETREE_DDR_1G}
	fi

	echo "KERNEL_DEVICETREE: ${KERNEL_DEVICETREE}"

	echo "=====ab update & vendor boot mode====="
	for aDts in ${KERNEL_DEVICETREE}; do
		sed -i 's/^#include \"partition_.*/#include "partition_mbox_ab.dtsi"/' ${KERNEL_DIR}/arch/${ARCH}/boot/dts/amlogic/$aDts.dts;
	done

	echo "================================="

	cd ${MAIN_FOLDER}
	./device/khadas/common/kernelbuild/build.sh
}

function build_common_4.9() {

    echo "------device/khadas/$1/build.config.meson.${ARCH}.trunk_4.9-----"
	cd ${MAIN_FOLDER}
	export BUILD_CONFIG=device/khadas/$1/build.config.meson.${ARCH}.trunk_4.9
	export TARGET_BUILD_KERNEL_4_9=true

	. ${MAIN_FOLDER}/${BUILD_CONFIG}
	export $(sed -n -e 's/\([^=]\)=.*/\1/p' ${MAIN_FOLDER}/${BUILD_CONFIG})
	echo "KERNEL_DEVICETREE: ${KERNEL_DEVICETREE}"
	if [ $CONFIG_AB_UPDATE ]; then
		echo "=====ab update mode====="
		for aDts in ${KERNEL_DEVICETREE}; do
			sed -i 's/^#include \"partition_.*/#include "partition_mbox_normal_dynamic_ab.dtsi"/' ${KERNEL_DIR}/arch/${ARCH}/boot/dts/amlogic/$aDts.dts;
		done
	else
		echo "=====normal mode====="
		for aDts in ${KERNEL_DEVICETREE}; do
			sed -i 's/^#include \"partition_.*/#include "partition_mbox_normal_dynamic.dtsi"/' ${KERNEL_DIR}/arch/${ARCH}/boot/dts/amlogic/$aDts.dts;
		done
	fi
	echo "================================="

	cd ${MAIN_FOLDER}
	./device/khadas/common/kernelbuild/build_kernel_4.9.sh
}

function build_common_5.4() {

	echo "------device/khadas/$1/build.config.meson.${ARCH}.trunk-----"
	cd ${MAIN_FOLDER}
	export BUILD_CONFIG=device/khadas/$1/build.config.meson.${ARCH}.trunk
	export TARGET_BUILD_KERNEL_4_9=false
	. ${MAIN_FOLDER}/${BUILD_CONFIG}
	export $(sed -n -e 's/\([^=]\)=.*/\1/p' ${MAIN_FOLDER}/${BUILD_CONFIG})

	if [ $CONFIG_KERNEL_FCC_PIP ]; then
		export KERNEL_DEVICETREE=${KERNEL_DEVICETREE_FCC_PIP}
		export CONFIG_KERNEL_FCC_PIP=true
	fi
	if [ $CONFIG_KERNEL_DDR_1G ]; then
		export KERNEL_DEVICETREE=${KERNEL_DEVICETREE_DDR_1G}
		export CONFIG_KERNEL_DDR_1G=true
	fi


	echo "KERNEL_DEVICETREE: ${KERNEL_DEVICETREE}"
	if [ $CONFIG_AB_GKI ]; then
		echo "=====normal mode====="
		for aDts in ${KERNEL_DEVICETREE}; do
			sed -i 's/^#include \"partition_.*/#include "partition_mbox.dtsi"/' ${KERNEL_DIR}/arch/${ARCH}/boot/dts/amlogic/$aDts.dts;
		done
	else
		echo "=====ab update & vendor boot mode====="
		for aDts in ${KERNEL_DEVICETREE}; do
			sed -i 's/^#include \"partition_.*/#include "partition_mbox_ab.dtsi"/' ${KERNEL_DIR}/arch/${ARCH}/boot/dts/amlogic/$aDts.dts;
		done
	fi
	echo "================================="

	cd ${MAIN_FOLDER}
	./device/khadas/common/kernelbuild/build.sh
}

function build_common() {
	if [ "$CONFIG_KERNEL_VERSION" = "4.9" ]; then
		build_common_4.9 $@
	else
		build_common_5.4 $@
	fi
}

function build() {
	# parser
	bin_path_parser $@

	export SKIP_MRPROPER=true
	unset SKIP_BUILD_KERNEL
	unset BUILD_ONE_MODULES
	unset SKIP_CP_KERNEL_HDR
	unset BUILD_KERNEL_ONLY
	unset SKIP_EXT_MODULES
	unset ARCH
	export PRODUCT_DIR=$1

	if [ $KERNEL_A32_SUPPORT ]; then
		export ARCH=arm
		export KERNEL_A32_SUPPORT=true
	else
		export ARCH=arm64
		unset KERNEL_A32_SUPPORT
	fi

	if [ "${CONFIG_KERNEL_VERSION}" == "" ]; then
		if [ "$1" = "franklin" -o "$1" = "ohm" -o "$1" = "elektra" -o "$1" = "newton" ]; then
			CONFIG_KERNEL_VERSION=4.9
			echo "CONFIG_KERNEL_VERSION: ${CONFIG_KERNEL_VERSION}"
		fi
	fi

	if [ "${CONFIG_ONE_MODULES}" != "" ]; then
		export SKIP_BUILD_KERNEL=true
		export BUILD_ONE_MODULES=${CONFIG_ONE_MODULES}
		export SKIP_CP_KERNEL_HDR=true
	fi

	if [ "${CONFIG_KERNEL_ONLY}" != "" ]; then
		export SKIP_EXT_MODULES=true
	fi

	option="${1}"
	case ${option} in
		deadpool)
			build_deadpool
			;;
		boreal)
			build_boreal
			;;
		*)
			build_common $@
			;;
	esac

	if [ $? -ne 0 ]; then
		echo "build kernel error"
		exit 1
	fi
}

function usage() {
  cat << EOF
  Usage:
    $(basename $0) --help

    kernel & modules standalone build script.

    you must use -v ** params

    command list:
    1. build kernel & modules for 5.4 GKI:
        ./$(basename $0) [config_name] -v 5.4

    2. build kernel & modules for 5.4 normal:
        ./$(basename $0) [config_name] -v 5.4 --nonGKI

    3. build kernel & modules for 4.9 normal:
        ./$(basename $0) [config_name] -v 4.9

    4. build kernel & modules for 4.9 virtual ab:
        ./$(basename $0) [config_name] -v 4.9 --ab

    5. clean
        ./$(basename $0) clean

    6. build one modules only
        ./$(basename $0) [config_name] -v 5.4 --modules module_path

    7. build kernel only
        ./$(basename $0) [config_name] -v 5.4 --kernel_only

    8. build kernel with different config
        ./$(basename $0) [config_name] -t [userdebug|user|eng]

    9. for 32-bit kernel & without --a32 option compile 64-bit kernel
        ./$(basename $0) [config_name] -v 4.9 --a32  //compile 32-bit kernel
        ./$(basename $0) [config_name] -v 4.9  //without --a32 option, compile 64-bit kernel

    you can use different params at the same time

    Example:
    1) ./mk newton -v 5.4 //5.4 GKI

    2) ./mk newton -v 5.4 --nonGKI   //5.4 nonGKI

    2) ./mk franklin -v 4.9   //4.9 normal

    3) ./mk clean

    4) ./mk newton -v 5.4 -t user   //5.4 GKI with additional meson64_a64_r_user_diffconfig

    5) ./mk franklin -v 4.9 --ab    //4.9 virtual_ab

    6) ./mk ohm -v 5.4 --modules hardware/amlogic/media_modules

    7) ./mk ohm -v 5.4 --kernel_only

    8) ./mk marconi -v 4.9 --a32  //32-bit kernel

EOF
  exit 1
}

function parser() {
	local i=0
	local j=0
	local argv=()
	for arg in "$@" ; do
		argv[$i]="$arg"
		i=$((i + 1))
	done
	i=0
	j=0
	while [ $i -lt $# ]; do
		arg="${argv[$i]}"
		i=$((i + 1)) # must place here
		case "$arg" in
			-h|--help|help)
				usage
				exit ;;
			-v)
				j=1 ;;
			clean|distclean|-distclean|--distclean)
				clean
				exit ;;
			*)
		esac
	done
	if [ "$j" == "0" ]; then
		usage
		exit
	fi
}

function bin_path_parser() {
	local i=0
	local argv=()
	for arg in "$@" ; do
		argv[$i]="$arg"
		i=$((i + 1))
	done
	i=0

	while [ $i -lt $# ]; do
		arg="${argv[$i]}"
		i=$((i + 1)) # must pleace here
		case "$arg" in
			-t)
				CONFIG_BOOTIMAGE="${argv[$i]}"
				echo "CONFIG_BOOTIMAGE: ${CONFIG_BOOTIMAGE}"
				export CONFIG_BOOTIMAGE
				continue ;;
			-v)
				CONFIG_KERNEL_VERSION="${argv[$i]}"
				echo "CONFIG_KERNEL_VERSION: ${CONFIG_KERNEL_VERSION}"
				continue ;;
			--a32)
				KERNEL_A32_SUPPORT=true
				continue ;;
			--ab|--ab_update)
				CONFIG_AB_UPDATE=true
				continue ;;
			--fccpip)
				CONFIG_KERNEL_FCC_PIP=true
				continue ;;
			--1g)
				CONFIG_KERNEL_DDR_1G=true
				continue ;;
			--nonAB)
				CONFIG_AB_GKI=true
				continue ;;
			--modules)
				CONFIG_ONE_MODULES="${argv[$i]}"
				continue ;;
			--kernel_only)
				CONFIG_KERNEL_ONLY=true
				continue ;;
			--builtin_modules)
				CONFIG_BUILTIN_MODULES=true
				echo "CONFIG_BUILTIN_MODULES: true"
				export CONFIG_BUILTIN_MODULES
				continue ;;
				*)
		esac
	done
}

function main() {
	if [ -z $1 ]
	then
		usage
		return
	fi

	MAIN_FOLDER=`pwd`
	parser $@
	build $@
}

main $@ # parse all paras to function
