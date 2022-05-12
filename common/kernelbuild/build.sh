#!/bin/bash

# Copyright (C) 2019 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Usage:
#   build/build.sh <make options>*
# or:
#   OUT_DIR=<out dir> DIST_DIR=<dist dir> build/build.sh <make options>*
#
# Example:
#   OUT_DIR=output DIST_DIR=dist build/build.sh -j24 V=1
#
#
# The following environment variables are considered during execution:
#
#   BUILD_CONFIG
#     Build config file to initialize the build environment from. The location
#     is to be defined relative to the repo root directory.
#     Defaults to 'build.config'.
#
#   OUT_DIR
#     Base output directory for the kernel build.
#     Defaults to <REPO_ROOT>/out/<BRANCH>.
#
#   DIST_DIR
#     Base output directory for the kernel distribution.
#     Defaults to <OUT_DIR>/dist
#
#   EXT_MODULES
#     Space separated list of external kernel modules to be build.
#
#   UNSTRIPPED_MODULES
#     Space separated list of modules to be copied to <DIST_DIR>/unstripped
#     for debugging purposes.
#
#   CC
#     Override compiler to be used. (e.g. CC=clang) Specifying CC=gcc
#     effectively unsets CC to fall back to the default gcc detected by kbuild
#     (including any target triplet). To use a custom 'gcc' from PATH, use an
#     absolute path, e.g.  CC=/usr/local/bin/gcc
#
#   LD
#     Override linker (flags) to be used.
#
#   ABI_DEFINITION
#     Location of the abi definition file relative to <REPO_ROOT>/KERNEL_DIR
#     If defined (usually in build.config), also copy that abi definition to
#     <OUT_DIR>/dist/abi.xml when creating the distribution.
#
#   KMI_WHITELIST
#     Location of the main KMI whitelist file relative to <REPO_ROOT>/KERNEL_DIR
#     If defined (usually in build.config), also copy that whitelist definition
#     to <OUT_DIR>/dist/abi_whitelist when creating the distribution.
#
#   ADDITIONAL_KMI_WHITELISTS
#     Location of secondary KMI whitelist files relative to
#     <REPO_ROOT>/KERNEL_DIR. If defined, these additional whitelists will be
#     appended to the main one before proceeding to the distribution creation.
#
# Environment variables to influence the stages of the kernel build.
#
#   SKIP_MRPROPER
#     if defined, skip `make mrproper`
#
#   SKIP_DEFCONFIG
#     if defined, skip `make defconfig`
#
#   PRE_DEFCONFIG_CMDS
#     Command evaluated before `make defconfig`
#
#   POST_DEFCONFIG_CMDS
#     Command evaluated after `make defconfig` and before `make`.
#
#   POST_KERNEL_BUILD_CMDS
#     Command evaluated after `make`.
#
#   TAGS_CONFIG
#     if defined, calls ./scripts/tags.sh utility with TAGS_CONFIG as argument
#     and exit once tags have been generated
#
#   IN_KERNEL_MODULES
#     if defined, install kernel modules
#
#   SKIP_EXT_MODULES
#     if defined, skip building and installing of external modules
#
#   DO_NOT_STRIP_MODULES
#     Keep debug information for distributed modules.
#     Note, modules will still be stripped when copied into the ramdisk.
#
#   EXTRA_CMDS
#     Command evaluated after building and installing kernel and modules.
#
#   SKIP_CP_KERNEL_HDR
#     if defined, skip installing kernel headers.
#
#   BUILD_BOOT_IMG
#     if defined, build a boot.img binary that can be flashed into the 'boot'
#     partition of an Android device. The boot image contains a header as per the
#     format defined by https://source.android.com/devices/bootloader/boot-image-header
#     followed by several components like kernel, ramdisk, DTB etc. The ramdisk
#     component comprises of a GKI ramdisk cpio archive concatenated with a
#     vendor ramdisk cpio archive which is then gzipped. It is expected that
#     all components are present in ${DIST_DIR}.
#
#     When the BUILD_BOOT_IMG flag is defined, the following flags that point to the
#     various components needed to build a boot.img also need to be defined.
#     - MKBOOTIMG_PATH=<path to the mkbootimg.py script which builds boot.img>
#       (defaults to tools/mkbootimg/mkbootimg.py)
#     - GKI_RAMDISK_PREBUILT_BINARY=<Name of the GKI ramdisk prebuilt which includes
#       the generic ramdisk components like init and the non-device-specific rc files>
#     - VENDOR_RAMDISK_BINARY=<Name of the vendor ramdisk binary which includes the
#       device-specific components of ramdisk like the fstab file and the
#       device-specific rc files.>
#     - KERNEL_BINARY=<name of kernel binary, eg. Image.lz4, Image.gz etc>
#     - BOOT_IMAGE_HEADER_VERSION=<version of the boot image header>
#       (defaults to 3)
#     - KERNEL_CMDLINE=<string of kernel parameters for boot>
#     - KERNEL_VENDOR_CMDLINE=<string of kernel parameters for vendor_boot>
#     - VENDOR_FSTAB=<Path to the vendor fstab to be included in the vendor
#       ramdisk>
#     If the BOOT_IMAGE_HEADER_VERSION is less than 3, two additional variables must
#     be defined:
#     - BASE_ADDRESS=<base address to load the kernel at>
#     - PAGE_SIZE=<flash page size>
#
#   BUILD_INITRAMFS
#     if defined, build a ramdisk containing all .ko files and resulting depmod artifacts
#
#   MODULES_OPTIONS
#     A /lib/modules/modules.options file is created on the ramdisk containing
#     the contents of this variable, lines should be of the form: options
#     <modulename> <param1>=<val> <param2>=<val> ...
#
#   TRIM_NONLISTED_KMI
#     if defined, enable the CONFIG_UNUSED_KSYMS_WHITELIST kernel config option
#     to un-export from the build any un-used and non-whitelisted (as per
#     KMI_WHITELIST) symbol.
#
# Note: For historic reasons, internally, OUT_DIR will be copied into
# COMMON_OUT_DIR, and OUT_DIR will be then set to
# ${COMMON_OUT_DIR}/${KERNEL_DIR}. This has been done to accommodate existing
# build.config files that expect ${OUT_DIR} to point to the output directory of
# the kernel build.
#
# The kernel is built in ${COMMON_OUT_DIR}/${KERNEL_DIR}.
# Out-of-tree modules are built in ${COMMON_OUT_DIR}/${EXT_MOD} where
# ${EXT_MOD} is the path to the module source code.

set -e

# rel_path <to> <from>
# Generate relative directory path to reach directory <to> from <from>
function rel_path() {
    local to=$1
    local from=$2
    local path=
    local stem=
    local prevstem=
    [ -n "$to" ] || return 1
    [ -n "$from" ] || return 1
    to=$(readlink -e "$to")
    from=$(readlink -e "$from")
    [ -n "$to" ] || return 1
    [ -n "$from" ] || return 1
    stem=${from}/
    while [ "${to#$stem}" == "${to}" -a "${stem}" != "${prevstem}" ]; do
        prevstem=$stem
        stem=$(readlink -e "${stem}/..")
        [ "${stem%/}" == "${stem}" ] && stem=${stem}/
        path=${path}../
    done
    echo ${path}${to#$stem}
}

export ROOT_DIR=$(readlink -f $(dirname $0)/../../../..)

# For module file Signing with the kernel (if needed)
FILE_SIGN_BIN=scripts/sign-file
SIGN_SEC=certs/signing_key.pem
SIGN_CERT=certs/signing_key.x509
SIGN_ALGO=sha512

# Save environment parameters before being overwritten by sourcing
# BUILD_CONFIG.
CC_ARG="${CC}"

source "${ROOT_DIR}/build/_setup_env.sh"
if [ $CONFIG_KERNEL_FCC_PIP ]; then
	export KERNEL_DEVICETREE=${KERNEL_DEVICETREE_FCC_PIP}
fi
if [ $CONFIG_KERNEL_DDR_1G ]; then
	export KERNEL_DEVICETREE=${KERNEL_DEVICETREE_DDR_1G}
fi

export MAKE_ARGS=$*
export MAKEFLAGS="-j$(nproc) ${MAKEFLAGS}"
export MODULES_STAGING_DIR=$(readlink -m ${COMMON_OUT_DIR}/staging)
export MODULES_PRIVATE_DIR=$(readlink -m ${COMMON_OUT_DIR}/private)
export UNSTRIPPED_DIR=${DIST_DIR}/unstripped
export KERNEL_UAPI_HEADERS_DIR=$(readlink -m ${COMMON_OUT_DIR}/kernel_uapi_headers)
export INITRAMFS_STAGING_DIR=${MODULES_STAGING_DIR}/initramfs_staging

export PATH=${TARGET_HOST_TOOL_PATH}:${TARGET_HOST_INCLUDE_PATH}:$PATH

cd ${ROOT_DIR}

export CLANG_TRIPLE CROSS_COMPILE CROSS_COMPILE_ARM32 ARCH SUBARCH MAKE_GOALS

# Restore the previously saved CC argument that might have been overridden by
# the BUILD_CONFIG.
[ -n "${CC_ARG}" ] && CC="${CC_ARG}"

# CC=gcc is effectively a fallback to the default gcc including any target
# triplets. An absolute path (e.g., CC=/usr/bin/gcc) must be specified to use a
# custom compiler.
[ "${CC}" == "gcc" ] && unset CC && unset CC_ARG

TOOL_ARGS=()

if [ -n "${CC}" ]; then
  TOOL_ARGS+=("CC=${CC}" "HOSTCC=${CC}")
fi

if [ -n "${LD}" ]; then
  TOOL_ARGS+=("LD=${LD}")
fi

if [ -n "${NM}" ]; then
  TOOL_ARGS+=("NM=${NM}")
fi

if [ -n "${OBJCOPY}" ]; then
  TOOL_ARGS+=("OBJCOPY=${OBJCOPY}")
fi

# Allow hooks that refer to $CC_LD_ARG to keep working until they can be
# updated.
CC_LD_ARG="${TOOL_ARGS[@]}"

mkdir -p ${OUT_DIR} ${DIST_DIR}

echo "========================================================"
echo " Setting up for build"
if [ -z "${SKIP_MRPROPER}" ] ; then
  set -x
  (cd ${KERNEL_DIR} && make "${TOOL_ARGS[@]}" O=${OUT_DIR} ${MAKE_ARGS} mrproper)
  set +x
fi

if [ -n "${PRE_DEFCONFIG_CMDS}" ]; then
  echo "========================================================"
  echo " Running pre-defconfig command(s):"
  set -x
  eval ${PRE_DEFCONFIG_CMDS}
  set +x
fi

if [ ! $KERNEL_A32_SUPPORT ]; then
    if [ -n "${CUSTOMER_GKI_DEFCONFIG}" ]; then
        GKI_EXT_MODULE_CFG=${KERNEL_DIR}/customer/arch/arm64/configs/${CUSTOMER_GKI_DEFCONFIG}
    else
        GKI_EXT_MODULE_CFG=${KERNEL_DIR}/arch/arm64/configs/meson64_gki_module_config
    fi
    GKI_EXT_MODULE_CFG_TMP=${GKI_EXT_MODULE_CFG}.tmp
    cp $GKI_EXT_MODULE_CFG $GKI_EXT_MODULE_CFG_TMP
fi

if [ -z "${SKIP_BUILD_KERNEL}" ] ; then

if [ -z "${SKIP_DEFCONFIG}" ] ; then
set -x
if [ $KERNEL_A32_SUPPORT ]; then
    cp ${KERNEL_DIR}/arch/arm/configs/meson64_a32_defconfig ${KERNEL_DIR}/arch/arm/configs/meson64_a32_tmp_defconfig
    if [ "$CONFIG_BOOTIMAGE" == "user" ];then
        cat ${KERNEL_DIR}/scripts/amlogic/meson64_r_user_diffconfig >> ${KERNEL_DIR}/arch/arm/configs/meson64_a32_tmp_defconfig
    fi
    (cd ${KERNEL_DIR} && make "${TOOL_ARGS[@]}" O=${OUT_DIR} ${MAKE_ARGS} meson64_a32_tmp_defconfig)
    rm -fr ${KERNEL_DIR}/arch/arm/configs/meson64_a32_tmp_defconfig
else
    if [ "$CONFIG_BUILTIN_MODULES" == true ];then
        echo "builtin_modules defconfig"
        if [ -n "${CUSTOMER_DEFCONFIG}" ]; then
            cat ${KERNEL_DIR}/customer/arch/arm64/configs/${CUSTOMER_DEFCONFIG} $GKI_EXT_MODULE_CFG_TMP > ${KERNEL_DIR}/arch/arm64/configs/meson64_a64_gki_defconfig
        else
            cat ${KERNEL_DIR}/arch/arm64/configs/meson64_a64_R_defconfig $GKI_EXT_MODULE_CFG_TMP > ${KERNEL_DIR}/arch/arm64/configs/meson64_a64_gki_defconfig
        fi
        sed -i 's/=m/=y/g' ${KERNEL_DIR}/arch/arm64/configs/meson64_a64_gki_defconfig
    else
        if [ -n "${CUSTOMER_DEFCONFIG}" ]; then
            cp ${KERNEL_DIR}/customer/arch/arm64/configs/${CUSTOMER_DEFCONFIG} ${KERNEL_DIR}/arch/arm64/configs/meson64_a64_gki_defconfig
        else
            cp ${KERNEL_DIR}/arch/arm64/configs/meson64_a64_R_defconfig ${KERNEL_DIR}/arch/arm64/configs/meson64_a64_gki_defconfig
        fi

    fi

    if [ ! -z "$BOARD_REMOVE_CONFIG" ];then
        echo BOARD_REMOVE_CONFIG = $BOARD_REMOVE_CONFIG
        for loop in `cat ${KERNEL_DIR}/scripts/amlogic/configs/$BOARD_REMOVE_CONFIG | grep "^CONFIG_"`; do
            echo "# $loop is not set" >> ${KERNEL_DIR}/arch/arm64/configs/meson64_a64_gki_defconfig
            sed -i "s/^${loop}=[ym]//" $GKI_EXT_MODULE_CFG_TMP
        done
    fi

    if [ "$CONFIG_BOOTIMAGE" == "user" ];then
        cat ${KERNEL_DIR}/scripts/amlogic/meson64_r_user_diffconfig >> ${KERNEL_DIR}/arch/arm64/configs/meson64_a64_gki_defconfig
    fi

    (cd ${KERNEL_DIR} && make "${TOOL_ARGS[@]}" O=${OUT_DIR} ${MAKE_ARGS} meson64_a64_gki_defconfig)
    rm -fr ${KERNEL_DIR}/arch/arm64/configs/meson64_a64_gki_defconfig
fi
set +x

function read_ext_module_config() {
    ALL_LINE=""
    while read LINE
    do
        if [[ $LINE != \#*  &&  $LINE != "" ]]; then
            ALL_LINE="$ALL_LINE"" ""$LINE"
        fi
    done < $1
    echo $ALL_LINE
}

if [ ! $KERNEL_A32_SUPPORT ]; then
    GKI_EXT_MODULE_CONFIG=$(read_ext_module_config $GKI_EXT_MODULE_CFG_TMP)
    export GKI_EXT_MODULE_CONFIG
fi

function read_ext_module_predefine() {
    PRE_DEFINE=""
    while read LINE
    do
        if [[ $LINE != \#* &&  $LINE != "" ]]; then
            TMP_CFG=${LINE%=*}
            PRE_DEFINE="$PRE_DEFINE"" -D""$TMP_CFG"
        fi
    done < $1
    echo $PRE_DEFINE
}

if [ ! $KERNEL_A32_SUPPORT ]; then
   GKI_EXT_MODULE_PREDEFINE=$(read_ext_module_predefine $GKI_EXT_MODULE_CFG_TMP)
   export GKI_EXT_MODULE_PREDEFINE
fi

if [ -n "${POST_DEFCONFIG_CMDS}" ]; then
  echo "========================================================"
  echo " Running pre-make command(s):"
  set -x
  eval ${POST_DEFCONFIG_CMDS}
  set +x
fi
fi

if [ -n "${TAGS_CONFIG}" ]; then
  echo "========================================================"
  echo " Running tags command:"
  set -x
  (cd ${KERNEL_DIR} && SRCARCH=${ARCH} ./scripts/tags.sh ${TAGS_CONFIG})
  set +x
  exit 0
fi

# Copy the abi_${arch}.xml file from the sources into the dist dir
if [ -n "${ABI_DEFINITION}" ]; then
  echo "========================================================"
  echo " Copying abi definition to ${DIST_DIR}/abi.xml"
  pushd $ROOT_DIR/$KERNEL_DIR
    cp "${ABI_DEFINITION}" ${DIST_DIR}/abi.xml
  popd
fi

# Copy the abi whitelist file from the sources into the dist dir
if [ -n "${KMI_WHITELIST}" ]; then
  echo "========================================================"
  echo " Generating abi whitelist definition to ${DIST_DIR}/abi_whitelist"
  pushd $ROOT_DIR/$KERNEL_DIR
    cp "${KMI_WHITELIST}" ${DIST_DIR}/abi_whitelist

    # If there are additional whitelists specified, append them
    if [ -n "${ADDITIONAL_KMI_WHITELISTS}" ]; then
      for whitelist in ${ADDITIONAL_KMI_WHITELISTS}; do
          echo >> ${DIST_DIR}/abi_whitelist
          cat "${whitelist}" >> ${DIST_DIR}/abi_whitelist
      done
    fi

    if [ -n "${TRIM_NONLISTED_KMI}" ]; then
        # Create the raw whitelist
        cat ${DIST_DIR}/abi_whitelist | \
                ${ROOT_DIR}/build/abi/flatten_whitelist > \
                ${OUT_DIR}/abi_whitelist.raw

        # Update the kernel configuration
        ./scripts/config --file ${OUT_DIR}/.config \
                -d UNUSED_SYMBOLS -e TRIM_UNUSED_KSYMS \
                --set-str UNUSED_KSYMS_WHITELIST ${OUT_DIR}/abi_whitelist.raw
        (cd ${OUT_DIR} && \
                make O=${OUT_DIR} "${TOOL_ARGS[@]}" ${MAKE_ARGS} olddefconfig)
    fi
  popd # $ROOT_DIR/$KERNEL_DIR
elif [ -n "${TRIM_NONLISTED_KMI}" ]; then
  echo "ERROR: TRIM_NONLISTED_KMI requires a KMI_WHITELIST" >&2
  exit 1
fi

echo "========================================================"
echo " Building kernel"

set -x
find ${OUT_DIR}/ -type f | grep "\.ko$" | xargs rm -fr

if [ $KERNEL_A32_SUPPORT ]; then
(cd ${OUT_DIR} && make O=${OUT_DIR} "${TOOL_ARGS[@]}" ${MAKE_ARGS} ${MAKE_GOALS} modules uImage dtbs LOADADDR=0x108000)
else
(cd ${OUT_DIR} && make O=${OUT_DIR} "${TOOL_ARGS[@]}" ${MAKE_ARGS} ${MAKE_GOALS})
fi
set +x

if [ -n "${POST_KERNEL_BUILD_CMDS}" ]; then
  echo "========================================================"
  echo " Running post-kernel-build command(s): ${POST_KERNEL_BUILD_CMDS}"
  set -x
  eval ${POST_KERNEL_BUILD_CMDS}
  set +x
fi

rm -rf ${MODULES_STAGING_DIR}
mkdir -p ${MODULES_STAGING_DIR}

if [ -z "${DO_NOT_STRIP_MODULES}" ]; then
    MODULE_STRIP_FLAG="INSTALL_MOD_STRIP=1"
fi

if [ -n "${BUILD_INITRAMFS}" -o  -n "${IN_KERNEL_MODULES}" ]; then
  echo "========================================================"
  echo " Installing kernel modules into staging directory"
  echo " make O=${OUT_DIR} "${TOOL_ARGS[@]}" ${MODULE_STRIP_FLAG} INSTALL_MOD_PATH=${MODULES_STAGING_DIR} ${MAKE_ARGS} modules_install)"

  (cd ${OUT_DIR} &&                                                           \
   make O=${OUT_DIR} "${TOOL_ARGS[@]}" ${MODULE_STRIP_FLAG}                   \
        INSTALL_MOD_PATH=${MODULES_STAGING_DIR} ${MAKE_ARGS} modules_install)
fi

fi

# basic common modules build as extern
if [ "$CONFIG_BUILTIN_MODULES" != true ];then
EXT_MODULES+="common/drivers/amlogic
common/sound/soc/amlogic
common/sound/soc/codecs/amlogic
"
fi

if [ -n "${BUILD_ONE_MODULES}" ] ; then
echo "===== reset EXT_MODULES"
unset EXT_MODULES
EXT_MODULES=${BUILD_ONE_MODULES}
fi

if [[ -z "${SKIP_EXT_MODULES}" ]] && [[ -n "${EXT_MODULES}" ]]; then
  echo "========================================================"
  echo " Building external modules and installing them into staging directory"

  for EXT_MOD in ${EXT_MODULES}; do
    # The path that we pass in via the variable M needs to be a relative path
    # relative to the kernel source directory. The source files will then be
    # looked for in ${KERNEL_DIR}/${EXT_MOD_REL} and the object files (i.e. .o
    # and .ko) files will be stored in ${OUT_DIR}/${EXT_MOD_REL}. If we
    # instead set M to an absolute path, then object (i.e. .o and .ko) files
    # are stored in the module source directory which is not what we want.
    EXT_MOD_REL=$(rel_path ${ROOT_DIR}/${EXT_MOD} ${KERNEL_DIR})
    # The output directory must exist before we invoke make. Otherwise, the
    # build system behaves horribly wrong.
    mkdir -p ${OUT_DIR}/${EXT_MOD_REL}
    set -x
    make -C ${EXT_MOD} M=${EXT_MOD_REL} KERNEL_SRC=${ROOT_DIR}/${KERNEL_DIR}  \
                       O=${OUT_DIR} "${TOOL_ARGS[@]}" ${MAKE_ARGS}
    make -C ${EXT_MOD} M=${EXT_MOD_REL} KERNEL_SRC=${ROOT_DIR}/${KERNEL_DIR}  \
                       O=${OUT_DIR} "${TOOL_ARGS[@]}" ${MODULE_STRIP_FLAG}    \
                       INSTALL_MOD_PATH=${MODULES_STAGING_DIR}                \
                       ${MAKE_ARGS} modules_install
    set +x
  done

fi

if [ -n "${EXTRA_CMDS}" ]; then
  echo "========================================================"
  echo " Running extra build command(s):"
  set -x
  eval ${EXTRA_CMDS}
  set +x
fi

if [ -z "${SKIP_BUILD_KERNEL}" ] ; then

OVERLAYS_OUT=""
for ODM_DIR in ${ODM_DIRS}; do
  OVERLAY_DIR=${ROOT_DIR}/device/${ODM_DIR}/overlays
  echo "**************echo OVERLAY_DIR: ${OVERLAY_DIR}"

  if [ -d ${OVERLAY_DIR} ]; then
    OVERLAY_OUT_DIR=${OUT_DIR}/overlays/${ODM_DIR}
    mkdir -p ${OVERLAY_OUT_DIR}
    make -C ${OVERLAY_DIR} DTC=${OUT_DIR}/scripts/dtc/dtc                     \
                           OUT_DIR=${OVERLAY_OUT_DIR} ${MAKE_ARGS}
    OVERLAYS=$(find ${OVERLAY_OUT_DIR} -name "*.dtbo")
    OVERLAYS_OUT="$OVERLAYS_OUT $OVERLAYS"
  fi
done

echo "========================================================"
echo " Copying files"
for FILE in $(cd ${OUT_DIR} && ls -1 ${FILES}); do
  if [ -f ${OUT_DIR}/${FILE} ]; then
    echo "  $FILE"
    cp -p ${OUT_DIR}/${FILE} ${DIST_DIR}/
  else
    echo "  $FILE is not a file, skipping"
  fi
done

for FILE in ${OVERLAYS_OUT}; do
  OVERLAY_DIST_DIR=${DIST_DIR}/$(dirname ${FILE#${OUT_DIR}/overlays/})
  echo "******************  ${FILE#${OUT_DIR}/}"
  mkdir -p ${OVERLAY_DIST_DIR}
  cp ${FILE} ${OVERLAY_DIST_DIR}/
done

fi

MODULES=$(find ${MODULES_STAGING_DIR} -type f -name "*.ko")
if [ -n "${MODULES}" ]; then
  if [ -n "${IN_KERNEL_MODULES}" -o -n "${EXT_MODULES}" ]; then
    echo "========================================================"
    echo " Copying modules files"
    for FILE in ${MODULES}; do
      echo "  ${FILE#${MODULES_STAGING_DIR}/}"
      cp -p ${FILE} ${DIST_DIR}
    done
  fi
  if [ -n "${BUILD_INITRAMFS}" ]; then
    echo "========================================================"
    echo " Creating initramfs"
    set -x
    rm -rf ${INITRAMFS_STAGING_DIR}
    # Depmod requires a version number; use 0.0 instead of determining the
    # actual kernel version since it is not necessary and will be removed for
    # the final initramfs image.
    mkdir -p ${INITRAMFS_STAGING_DIR}/lib/modules/0.0/kernel/
    cp -r ${MODULES_STAGING_DIR}/lib/modules/*/kernel/* ${INITRAMFS_STAGING_DIR}/lib/modules/0.0/kernel/
    cp ${MODULES_STAGING_DIR}/lib/modules/*/modules.order ${INITRAMFS_STAGING_DIR}/lib/modules/0.0/modules.order
    cp ${MODULES_STAGING_DIR}/lib/modules/*/modules.builtin ${INITRAMFS_STAGING_DIR}/lib/modules/0.0/modules.builtin

    if [ -n "${EXT_MODULES}" ]; then
      mkdir -p ${INITRAMFS_STAGING_DIR}/lib/modules/0.0/extra/
      cp -r ${MODULES_STAGING_DIR}/lib/modules/*/extra/* ${INITRAMFS_STAGING_DIR}/lib/modules/0.0/extra/
      (cd ${INITRAMFS_STAGING_DIR}/lib/modules/0.0/ && \
          find extra -type f -name "*.ko" | sort >> modules.order)
    fi

    if [ -n "${DO_NOT_STRIP_MODULES}" ]; then
      # strip debug symbols off initramfs modules
      find ${INITRAMFS_STAGING_DIR} -type f -name "*.ko" \
        -exec ${OBJCOPY:${CROSS_COMPILE}strip} --strip-debug {} \;
    fi

    # Re-run depmod to detect any dependencies between in-kernel and external
    # modules. Then, create modules.load based on all the modules compiled.
    (
      set +x
      set +e # disable exiting of error so we can add extra comments
      cd ${INITRAMFS_STAGING_DIR}
      DEPMOD_OUTPUT=$(depmod -e -F ${DIST_DIR}/System.map -b . 0.0 2>&1)
      if [[ "$?" -ne 0 ]]; then
        echo "$DEPMOD_OUTPUT"
        exit 1;
      fi
      echo "$DEPMOD_OUTPUT"
      if [[ -n $(echo $DEPMOD_OUTPUT | grep "needs unknown symbol") ]]; then
        echo "ERROR: out-of-tree kernel module(s) need unknown symbol(s)"
        exit 1
      fi
      set -e
      set -x
    )
    cp ${INITRAMFS_STAGING_DIR}/lib/modules/0.0/modules.order ${INITRAMFS_STAGING_DIR}/lib/modules/0.0/modules.load
    cp ${INITRAMFS_STAGING_DIR}/lib/modules/0.0/modules.order ${DIST_DIR}/modules.load
    echo "${MODULES_OPTIONS}" > ${INITRAMFS_STAGING_DIR}/lib/modules/0.0/modules.options
    mv ${INITRAMFS_STAGING_DIR}/lib/modules/0.0/* ${INITRAMFS_STAGING_DIR}/lib/modules/.
    rmdir ${INITRAMFS_STAGING_DIR}/lib/modules/0.0

    if [ "${BOOT_IMAGE_HEADER_VERSION}" -eq "3" ]; then
      mkdir -p ${INITRAMFS_STAGING_DIR}/first_stage_ramdisk
      if [ -f "${VENDOR_FSTAB}" ]; then
        cp ${VENDOR_FSTAB} ${INITRAMFS_STAGING_DIR}/first_stage_ramdisk/.
      fi
    fi

    (cd ${INITRAMFS_STAGING_DIR} && find . | cpio -H newc -o > ${MODULES_STAGING_DIR}/initramfs.cpio)
    gzip -fc ${MODULES_STAGING_DIR}/initramfs.cpio > ${MODULES_STAGING_DIR}/initramfs.cpio.gz
    mv ${MODULES_STAGING_DIR}/initramfs.cpio.gz ${DIST_DIR}/initramfs.img
    set +x
  fi
fi

if [ -n "${UNSTRIPPED_MODULES}" ]; then
  echo "========================================================"
  echo " Copying unstripped module files for debugging purposes (not loaded on device)"
  mkdir -p ${UNSTRIPPED_DIR}
  for MODULE in ${UNSTRIPPED_MODULES}; do
    find ${MODULES_PRIVATE_DIR} -name ${MODULE} -exec cp {} ${UNSTRIPPED_DIR} \;
  done
fi

if [ -z "${SKIP_CP_KERNEL_HDR}" ]; then
  echo "========================================================"
  echo " Installing UAPI kernel headers:"
  mkdir -p "${KERNEL_UAPI_HEADERS_DIR}/usr"
  make -C ${OUT_DIR} O=${OUT_DIR} "${TOOL_ARGS[@]}"                           \
          INSTALL_HDR_PATH="${KERNEL_UAPI_HEADERS_DIR}/usr" ${MAKE_ARGS}      \
          headers_install
  # The kernel makefiles create files named ..install.cmd and .install which
  # are only side products. We don't want those. Let's delete them.
  find ${KERNEL_UAPI_HEADERS_DIR} \( -name ..install.cmd -o -name .install \) -exec rm '{}' +
  KERNEL_UAPI_HEADERS_TAR=${DIST_DIR}/kernel-uapi-headers.tar.gz
  echo " Copying kernel UAPI headers to ${KERNEL_UAPI_HEADERS_TAR}"
  tar -czf ${KERNEL_UAPI_HEADERS_TAR} --directory=${KERNEL_UAPI_HEADERS_DIR} usr/
fi

if [ -z "${SKIP_CP_KERNEL_HDR}" ] ; then
  echo "========================================================"
  KERNEL_HEADERS_TAR=${DIST_DIR}/kernel-headers.tar.gz
  echo " Copying kernel headers to ${KERNEL_HEADERS_TAR}"
  pushd $ROOT_DIR/$KERNEL_DIR
    find arch include $OUT_DIR -name *.h -print0               \
            | tar -czf $KERNEL_HEADERS_TAR                     \
              --absolute-names                                 \
              --dereference                                    \
              --transform "s,.*$OUT_DIR,,"                     \
              --transform "s,^,kernel-headers/,"               \
              --null -T -
  popd
fi

echo "========================================================"
echo " Files copied to ${DIST_DIR}"

if [ ! -z "${BUILD_BOOT_IMG}" ] ; then
    echo "************build boot img***********"
    if [ -z "${BOOT_IMAGE_HEADER_VERSION}" ]; then
        BOOT_IMAGE_HEADER_VERSION="3"
    fi
    MKBOOTIMG_BASE_ADDR=
    MKBOOTIMG_PAGE_SIZE=
    MKBOOTIMG_BOOT_CMDLINE=
    if [ -n  "${BASE_ADDRESS}" ]; then
        MKBOOTIMG_BASE_ADDR="--base ${BASE_ADDRESS}"
    fi
    if [ -n  "${PAGE_SIZE}" ]; then
        MKBOOTIMG_PAGE_SIZE="--pagesize ${PAGE_SIZE}"
    fi
    if [ -n "${KERNEL_CMDLINE}" ]; then
        MKBOOTIMG_BOOT_CMDLINE="--cmdline \"${KERNEL_CMDLINE}\""
    fi

    DTB_FILE_LIST=$(find ${DIST_DIR} -name "*.dtb")
    if [ -z "${DTB_FILE_LIST}" ]; then
        echo "No *.dtb files found in ${DIST_DIR}"
        exit 1
    fi
    cat $DTB_FILE_LIST > ${DIST_DIR}/dtb.img

    set -x
    MKBOOTIMG_RAMDISKS=()
    for ramdisk in ${VENDOR_RAMDISK_BINARY} \
               "${MODULES_STAGING_DIR}/initramfs.cpio"; do
        if [ -f "${DIST_DIR}/${ramdisk}" ]; then
            MKBOOTIMG_RAMDISKS+=("${DIST_DIR}/${ramdisk}")
        else
            if [ -f "${ramdisk}" ]; then
                MKBOOTIMG_RAMDISKS+=("${ramdisk}")
            fi
        fi
    done
    set +e # disable exiting of error so gzip -t can be handled properly
    for ((i=0; i<"${#MKBOOTIMG_RAMDISKS[@]}"; i++)); do
        TEST_GZIP=$(gzip -t "${MKBOOTIMG_RAMDISKS[$i]}" 2>&1 > /dev/null)
        if [ "$?" -eq 0 ]; then
            CPIO_NAME=$(echo "${MKBOOTIMG_RAMDISKS[$i]}" | sed -e 's/\(.\+\)\.[a-z]\+$/\1.cpio/')
            gzip -cd "${MKBOOTIMG_RAMDISKS[$i]}" > ${CPIO_NAME}
            MKBOOTIMG_RAMDISKS[$i]=${CPIO_NAME}
        fi
    done
    set -e # re-enable exiting on errors
    if [ "${#MKBOOTIMG_RAMDISKS[@]}" -gt 0 ]; then
        cat ${MKBOOTIMG_RAMDISKS[*]} | gzip - > ${DIST_DIR}/ramdisk.gz
    else
        echo "No ramdisk found. Please provide a GKI and/or a vendor ramdisk."
        exit 1
    fi
    set -x

    if [ -z "${MKBOOTIMG_PATH}" ]; then
        MKBOOTIMG_PATH="tools/mkbootimg/mkbootimg.py"
    fi
    if [ ! -f "$MKBOOTIMG_PATH" ]; then
        echo "mkbootimg.py script not found. MKBOOTIMG_PATH = $MKBOOTIMG_PATH"
        exit 1
    fi

    if [ ! -f "${DIST_DIR}/$KERNEL_BINARY" ]; then
        echo "kernel binary(KERNEL_BINARY = $KERNEL_BINARY) not present in ${DIST_DIR}"
        exit 1
    fi

    VENDOR_BOOT_ARGS=
    MKBOOTIMG_BOOT_RAMDISK="--ramdisk ${DIST_DIR}/ramdisk.gz"
    if [ "${BOOT_IMAGE_HEADER_VERSION}" -eq "3" ]; then
        MKBOOTIMG_VENDOR_CMDLINE=
        if [ -n "${KERNEL_VENDOR_CMDLINE}" ]; then
            MKBOOTIMG_VENDOR_CMDLINE="--vendor_cmdline \"${KERNEL_VENDOR_CMDLINE}\""
        fi

        MKBOOTIMG_BOOT_RAMDISK=
        if [ -f "${GKI_RAMDISK_PREBUILT_BINARY}" ]; then
            MKBOOTIMG_BOOT_RAMDISK="--ramdisk ${GKI_RAMDISK_PREBUILT_BINARY}"
        fi

        VENDOR_BOOT_ARGS="--vendor_boot ${DIST_DIR}/vendor_boot.img \
            --vendor_ramdisk ${DIST_DIR}/ramdisk.gz ${MKBOOTIMG_VENDOR_CMDLINE}"
    fi

    # (b/141990457) Investigate parenthesis issue with MKBOOTIMG_BOOT_CMDLINE when
    # executed outside of this "bash -c".
    (set -x; bash -c "python $MKBOOTIMG_PATH --kernel ${DIST_DIR}/$KERNEL_BINARY \
        ${MKBOOTIMG_BOOT_RAMDISK} \
        --dtb ${DIST_DIR}/dtb.img --header_version $BOOT_IMAGE_HEADER_VERSION \
        ${MKBOOTIMG_BASE_ADDR} ${MKBOOTIMG_PAGE_SIZE} ${MKBOOTIMG_BOOT_CMDLINE} \
        -o ${DIST_DIR}/boot.img ${VENDOR_BOOT_ARGS}"
    )

    set +x
    echo "boot image created at ${DIST_DIR}/boot.img"
fi

echo "========================================================"
echo " Files copied to device dir"
DTBTOOL=${ROOT_DIR}/device/amlogic/common/kernelbuild/dtbTool
DTCTOOL=${ROOT_DIR}/device/amlogic/common/kernelbuild/dtc
DTIMGTOOL=${ROOT_DIR}/device/amlogic/common/kernelbuild/mkdtimg

rm -rf ${ROOT_DIR}/${PRODUCT_DIRNAME}-kernel/5.4/lib/*
mkdir -p ${ROOT_DIR}/${PRODUCT_DIRNAME}-kernel/5.4/lib/firmware/video/
mkdir -p ${ROOT_DIR}/${PRODUCT_DIRNAME}-kernel/5.4/lib/modules/
cp ${OUT_DIR}/../vendor_lib/firmware/video/* ${ROOT_DIR}/${PRODUCT_DIRNAME}-kernel/5.4/lib/firmware/video/
cp ${OUT_DIR}/../vendor_lib/optee* ${ROOT_DIR}/${PRODUCT_DIRNAME}-kernel/5.4/lib/
cp ${OUT_DIR}/../vendor_lib/modules/* ${ROOT_DIR}/${PRODUCT_DIRNAME}-kernel/5.4/lib/modules/
if [ $KERNEL_A32_SUPPORT ]; then
    cp ${OUT_DIR}/arch/arm/boot/uImage ${ROOT_DIR}/${PRODUCT_DIRNAME}-kernel/5.4/
else
    cp ${OUT_DIR}/arch/arm64/boot/Image.gz ${ROOT_DIR}/${PRODUCT_DIRNAME}-kernel/5.4/
fi

if [ -z "${SKIP_BUILD_KERNEL}" ] ; then

echo "====copy dtb====== ${KERNEL_DEVICETREE}"
devicenum=$(echo "x${KERNEL_DEVICETREE}x" | awk '{print NF}')
echo "=========devicenum: ${devicenum}"

if [ ${devicenum} == 1 ]; then
    echo "===single dts==="
    if [ $KERNEL_A32_SUPPORT ]; then
        if [ "${CUSTOMER_DTB}" == true ]; then
            cp -f ${OUT_DIR}/customer/arch/arm/boot/dts/${KERNEL_DEVICETREE}.dtb ${ROOT_DIR}/${PRODUCT_DIRNAME}-kernel/5.4/${BOARD_DEVICENAME}.dtb
        else
            cp -f ${OUT_DIR}/arch/arm/boot/dts/amlogic/${KERNEL_DEVICETREE}.dtb ${ROOT_DIR}/${PRODUCT_DIRNAME}-kernel/5.4/${BOARD_DEVICENAME}.dtb
        fi
    else
        if [ "${CUSTOMER_DTB}" == true ]; then
            cp -f ${OUT_DIR}/customer/arch/arm64/boot/dts/${KERNEL_DEVICETREE}.dtb ${ROOT_DIR}/${PRODUCT_DIRNAME}-kernel/5.4/${BOARD_DEVICENAME}.dtb
        else
            if [ $CONFIG_KERNEL_FCC_PIP ]; then
                if [[ ${PRODUCT_DIRNAME} == *"ohm"* ]]; then
                    cp -f ${OUT_DIR}/arch/arm64/boot/dts/amlogic/${KERNEL_DEVICETREE}.dtb ${ROOT_DIR}/${PRODUCT_DIRNAME}-kernel/5.4/ohm_mxl258c.dtb
                elif [[ ${PRODUCT_DIRNAME} == *"oppencas"* ]]; then
                    cp -f ${OUT_DIR}/arch/arm64/boot/dts/amlogic/${KERNEL_DEVICETREE}.dtb ${ROOT_DIR}/${PRODUCT_DIRNAME}-kernel/5.4/oppencas_mxl258c.dtb
				elif [[ ${PRODUCT_DIRNAME} == *"oppen"* ]]; then
                    cp -f ${OUT_DIR}/arch/arm64/boot/dts/amlogic/${KERNEL_DEVICETREE}.dtb ${ROOT_DIR}/${PRODUCT_DIRNAME}-kernel/5.4/oppen_mxl258c.dtb
		else
                    cp -f ${OUT_DIR}/arch/arm64/boot/dts/amlogic/${KERNEL_DEVICETREE}.dtb ${ROOT_DIR}/${PRODUCT_DIRNAME}-kernel/5.4/${BOARD_DEVICENAME}.dtb
                fi
            else
                cp -f ${OUT_DIR}/arch/arm64/boot/dts/amlogic/${KERNEL_DEVICETREE}.dtb ${ROOT_DIR}/${PRODUCT_DIRNAME}-kernel/5.4/${BOARD_DEVICENAME}.dtb
            fi
        fi
    fi
else
    echo "===multi dts==="
    mkdir -p ${OUT_DIR}/../multi_dts
    for aDts in ${KERNEL_DEVICETREE}; do
        if [ $KERNEL_A32_SUPPORT ]; then
            if [ "${CUSTOMER_DTB}" == true ]; then
                cp ${OUT_DIR}/customer/arch/arm/boot/dts/$aDts.dtb ${OUT_DIR}/../multi_dts/
            else
                cp ${OUT_DIR}/arch/arm/boot/dts/amlogic/$aDts.dtb ${OUT_DIR}/../multi_dts/
            fi
        else
            if [ "${CUSTOMER_DTB}" == true ]; then
                cp ${OUT_DIR}/customer/arch/arm64/boot/dts/$aDts.dtb ${OUT_DIR}/../multi_dts/
            else
                cp ${OUT_DIR}/arch/arm64/boot/dts/amlogic/$aDts.dtb ${OUT_DIR}/../multi_dts/
            fi
        fi
    done
    ${DTBTOOL} -o ${ROOT_DIR}/${PRODUCT_DIRNAME}-kernel/5.4/${BOARD_DEVICENAME}.dtb -p ${OUT_DIR}/scripts/dtc/ ${OUT_DIR}/../multi_dts/
    if [ $? -ne 0 ]; then
        echo "build multi dts error"
        exit 1
    fi
fi

echo "===build dtbo==="
if [ $KERNEL_A32_SUPPORT ]; then
    ${DTCTOOL} -@ -O dtb -o ${OUT_DIR}/${DTBO_DEVICETREE}.dtbo common/arch/arm/boot/dts/amlogic/${DTBO_DEVICETREE}.dts
else
    ${DTCTOOL} -@ -O dtb -o ${OUT_DIR}/${DTBO_DEVICETREE}.dtbo common/arch/arm64/boot/dts/amlogic/${DTBO_DEVICETREE}.dts
fi
${DTIMGTOOL} create ${ROOT_DIR}/${PRODUCT_DIRNAME}-kernel/5.4/dtbo.img ${OUT_DIR}/${DTBO_DEVICETREE}.dtbo
if [ $? -ne 0 ]; then
    echo "build dtbo error"
    exit 1
fi

fi

# No trace_printk use on build server build
if readelf -a ${DIST_DIR}/vmlinux 2>&1 | grep -q trace_printk_fmt; then
  echo "========================================================"
  echo "WARN: Found trace_printk usage in vmlinux."
  echo ""
  echo "trace_printk will cause trace_printk_init_buffers executed in kernel"
  echo "start, which will increase memory and lead warning shown during boot."
  echo "We should not carry trace_printk in production kernel."
  echo ""
  if [ ! -z "${STOP_SHIP_TRACEPRINTK}" ]; then
    echo "ERROR: stop ship on trace_printk usage." 1>&2
    exit 1
  fi
fi


echo "======= copy builtin modules ======"
RAMDISK_TARGET=${ROOT_DIR}/${PRODUCT_DIRNAME}-kernel/5.4/ramdisk/
rm -fr ${RAMDISK_TARGET}/
mkdir -p ${RAMDISK_TARGET}/lib/modules/

if [ "$CONFIG_BUILTIN_MODULES" == true ];then
    echo "builtin modules, skip copy!"
    exit 0;
fi

for loop in `find ${MODULES_STAGING_DIR}/lib/modules/*/kernel/ -type f | grep "\.ko$"`
do
    cp $loop ${RAMDISK_TARGET}/lib/modules/
done

# copy extra ko to ramdisk
for loop in `find ${COMMON_OUT_DIR}/common/drivers/amlogic/ -type f | grep "\.ko$"`
do
    cp $loop ${RAMDISK_TARGET}/lib/modules/
done

# copy extra ko to ramdisk
for loop in `find ${COMMON_OUT_DIR}/common/sound/soc/ -type f | grep "\.ko$"`
do
    cp $loop ${RAMDISK_TARGET}/lib/modules/
done

if [ ! $KERNEL_A32_SUPPORT ]; then
   rm $GKI_EXT_MODULE_CFG_TMP -fr
fi
