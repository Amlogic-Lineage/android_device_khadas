#! /bin/bash

# usage() : quick compile help guide
#
# Project Config : add/remove new config
#
# get_project_path() : some project need get relative path that store uboot, like anning is ampere/anning
#
# read_platform_type() : select platform type, li
#
#


# Usage
########################################################################################################################################################################
# the scripts only receive one option or none.
usage() {
    printf "Usage: ./device/khadas/common/quick_compile.sh [OPTION]\n"
    printf "If no OPTION, build otapackage\n"
    printf "[OPTION]\n"
    printf "    uboot         : build someone uboot\n"
    printf "    all-uboot     : build all chips uboot\n"
    printf "    bootimage     : build boot image\n"
    printf "    logoimg       : build logo image\n"
#    printf "    recoveryimage : build recovery image\n"
    printf "    systemimage   : build system image\n"
    printf "    vendorimage   : build vendor image\n"
    printf "    odm_image     : build odm image\n"
    printf "    dtbimage      : build dts image\n"
#    printf "    build-modules-quick   : build media modules library\n"
    exit
}

########################################################################################################################################################################

# Project Config
########################################################################################################################################################################
#Project Name                  SOC Name              Hardware Name             lunch project name           uboot compile params               tdk path
project[1]="Franklin"       ;soc[1]="S905X2"         ;hardware[1]="U212"       ; module[1]="franklin"      ;uboot[1]="g12a_u212_v1"         ;tdk[1]="g12a/bl32.img"
project[2]="Newton"         ;soc[2]="S905X3"         ;hardware[2]="AC215"      ; module[2]="newton"        ;uboot[2]="sm1_ac215_v1"         ;tdk[2]="g12a/bl32.img"
project[3]="Marconi"        ;soc[3]="T962X2"         ;hardware[3]="X301"       ; module[3]="marconi"       ;uboot[3]="tl1_x301_v1"          ;tdk[3]="tl1/bl32.img"
project[4]="Dalton"         ;soc[4]="T962E2"         ;hardware[4]="AB311"      ; module[4]="dalton"        ;uboot[4]="tm2_t962e2_ab311_v1"  ;tdk[4]="tm2/bl32.img"
project[5]="OHM"            ;soc[5]="S905X4"         ;hardware[5]="AH212"      ; module[5]="ohm"           ;uboot[5]="sc2_ah212"            ;tdk[5]="buildIn"
project[6]="REDI"           ;soc[6]="T950D4/T950X4"  ;hardware[6]="AM301/AM311"; module[6]="redi"          ;uboot[6]="t5d_am301_v1"         ;tdk[6]="t5d/bl32.img"
project[7]="OPPEN"          ;soc[7]="S905Y4"         ;hardware[7]="AP222"      ; module[7]="oppen"         ;uboot[7]="s4_ap222"             ;tdk[7]="v3_s4/s905y4"
project[8]="PLANCK"         ;soc[8]="S805X2"         ;hardware[8]="AQ222"      ; module[8]="planck"        ;uboot[8]="s4_aq222"             ;tdk[8]="v3_s4/s805x2"
project[9]="OHMCAS"         ;soc[9]="S905C2"         ;hardware[9]="905C2AH232" ; module[9]="ohmcas"        ;uboot[9]="sc2_ah232"            ;tdk[9]="buildIn"
project[10]="AP201"         ;soc[10]="S905Y4"        ;hardware[10]="AP201"     ; module[10]="ap201"        ;uboot[10]="s4_ap201"            ;tdk[10]="buildIn"
project[11]="Ohm_mxl258c"   ;soc[11]="S905X4"        ;hardware[11]="AH212"     ; module[11]="ohm_mxl258c"  ;uboot[11]="sc2_ah212"           ;tdk[11]="buildIn"
project[12]="Smith"         ;soc[12]="T965D4"        ;hardware[12]="AR321"     ; module[12]="smith"        ;uboot[12]="t3_t965d4"           ;tdk[12]="buildIn"
project[13]="T982_AR301"    ;soc[13]="T982"          ;hardware[13]="AR301"     ; module[13]="t982_ar301"   ;uboot[13]="t3_t982"             ;tdk[13]="buildIn"
project[14]="OPPENCAS"      ;soc[14]="S905C3"        ;hardware[14]="AP232"     ; module[14]="oppencas"     ;uboot[14]="s4_ap232"            ;tdk[14]="v3_s4/s905c3"
project[15]="Oppen_mxl258c" ;soc[15]="S905Y4"        ;hardware[15]="AP222"     ; module[15]="oppen_mxl258c";uboot[15]="s4_ap222"            ;tdk[15]="v3_s4/s905y4"
project[16]="Oppencas_mxl258c" ;soc[16]="S905C3"     ;hardware[16]="AP232"     ; module[16]="oppencas_mxl258c";uboot[16]="s4_ap232"         ;tdk[16]="v3_s4/s905y4"
project[17]="Franklin"      ;soc[17]="S905X2"        ;hardware[17]="U212"      ; module[17]="franklin"     ;uboot[17]="g12a_u212_v1"        ;tdk[17]="g12a/bl32.img"
project[18]="Franklin_Hybrid";soc[18]="S905X2"       ;hardware[18]="U215"      ; module[18]="franklin_hybrid"   ;uboot[18]="g12a_u215_v1"  ;tdk[18]="g12a/bl32.img"
########################################################################################################################################################################


# initial get_project_path to get uboot store path.
########################################################################################################################################################################
get_project_path() {
    # if exists sub-project (like anning relative to ampere), need add the new config in this segment.
    if [[ ${module[platform_type]} == "franklin_hybrid" ]]; then
        project_path="franklin/${module[platform_type]}"
    elif [[ ${module[platform_type]} == "newton_hybrid" || ${module[platform_type]} == "ac214" || ${module[platform_type]} == "ac212" ]]; then
        project_path="newton/${module[platform_type]}"
    elif [[ ${module[platform_type]} == "anning" || ${module[platform_type]} == "curie" ]]; then
        project_path="ampere/${module[platform_type]}"
    elif [[ ${module[platform_type]} == "ohm_mxl258c" ]]; then
        project_path="ohm"
    elif [[ ${module[platform_type]} == "oppen_mxl258c" ]]; then
        project_path="oppen"
	elif [[ ${module[platform_type]} == "oppencas_mxl258c" ]]; then
        project_path="oppencas"
    else
        project_path=${module[platform_type]}
    fi
}
########################################################################################################################################################################

# Read Platform config
# Through the input number, to get project-name/project-path/uboot-params
# uboot-params : how to build uboot.
# project-path : how to replace the newest uboot.
# project-name : how to build the code.
########################################################################################################################################################################
read_platform_type() {
    # compile all uboot, no need select platform.
    if [[ $params == "all-uboot" ]]; then
        return
    fi
    while true :
    do
        printf "[%3s]   [%15s]   [%15s]  [%15s]\n" "NUM" "PROJECT" "SOC TYPE" "HARDWARE TYPE"
        echo "-----------------------------------------------------------------"
        for i in `seq ${#project[@]}`;do
            printf "[%3d]   [%15s]  [%15s]  [%15s]\n" $i ${project[i]} ${soc[i]} ${hardware[i]}
        done

        echo "-----------------------------------------------------------------"
        read -p "Please input platform NUM ([1 ~ ${#project[@]}], default 1 ):" platform_type

        if [ ${#platform_type} -eq 0 ]; then
            platform_type=1
            break
        fi

        if [[ $platform_type -lt 1 || $platform_type -gt ${#project[@]} ]]; then
            echo -e "\nError: The platform NUM is illegal!!! Need input again [1 ~ ${#project[@]}]\n"
            echo -e "Please click Enter to continue"
            read
        else
            break
        fi
    done
    echo "Input NUM is [${platform_type}], [${module[platform_type]}]"
}
########################################################################################################################################################################

# Get Android Type: AOSP/DRM/GTVS
########################################################################################################################################################################
read_android_type() {
    while true :
    do
        echo -e \
        "Select compile Android verion type lists:\n"\
        "[NUM]   [Android Version]\n" \
        "[  1]   [AOSP]\n" \
        "[  2]   [DRM ]\n" \
        "[  3]   [GTVS](need google gms zip)\n" \
        "--------------------------------------------\n"

        if [ -d "vendor/google_gtvs" ];then
            default=3
        else
            default=2
        fi
        read -p "Please input Android Version (default $default):" uboot_drm_type
        if [ ${#uboot_drm_type} -eq 0 ]; then
            uboot_drm_type=$default
            break
        fi
        if [[ $uboot_drm_type -lt 1 || $uboot_drm_type -gt 3 ]];then
            echo -e "\nError: The Android Version is illegal, please Input again [1 ~ 3]}\n"
            echo -e "Please click Enter to continue"
            read
        else
            break
        fi
    done
}
########################################################################################################################################################################

# Compile Uboot throuth params
########################################################################################################################################################################
compile_uboot() {
    uboot_name=${uboot[platform_type]}
    tdk_name=${tdk[platform_type]}
    cd bootloader/uboot

    if [ $uboot_drm_type -gt 1 ]; then
        compile_bl32="--bl32 ../../vendor/amlogic/common/tdk/secureos/$tdk_name"
        if [[ $tdk_name == "buildIn" || $tdk_name =~ "v3" ]]; then
            compile_bl32=""
        fi

        if [ $uboot_drm_type -eq 3 ]; then
            compile_avb="--avb2"
        fi
    else
        #S4 AOSP version need add bl32
        if [[ $tdk_name =~ "v3" ]]; then
            compile_bl32="--bl32 bl32_3.8/bin/${tdk_name##*v3_}/blob-bl32.8m.bin.signed"
        fi
    fi
    echo -e "[./mk $uboot_name $compile_bl32 --vab $compile_avb]\n"
    ./mk $uboot_name $compile_bl32 --vab $compile_avb;


    if [ -f "build/u-boot.bin.signed" ];then
        cp build/u-boot.bin.signed ../../device/khadas/$project_path/bootloader.img
        cp build/u-boot.bin.usb.signed ../../device/khadas/$project_path/upgrade/
        cp build/u-boot.bin.sd.bin.signed ../../device/khadas/$project_path/upgrade/
    else
        cp build/u-boot.bin ../../device/khadas/$project_path/bootloader.img;
        cp build/u-boot.bin.usb.bl2 ../../device/khadas/$project_path/upgrade/u-boot.bin.usb.bl2;
        cp build/u-boot.bin.usb.tpl ../../device/khadas/$project_path/upgrade/u-boot.bin.usb.tpl;
        cp build/u-boot.bin.sd.bin ../../device/khadas/$project_path/upgrade/u-boot.bin.sd.bin;
    fi
    cd ../../
}
########################################################################################################################################################################

print_uboot_info() {
    echo -e "\n\ndevice: update uboot [1/1]\n"
    echo -e "PD#SWPL-19355\n"
    echo -e "Problem:"
    echo -e "source code update, need update bootloader\n"
    echo "Solution:"
    cd bootloader/uboot-repo/bl2/bin/
    echo "bl2       : "$(git log --pretty=format:"%H" -1); cd ../../../../
    cd bootloader/uboot-repo/bl30/src_ao/
    echo "bl30      : "$(git log --pretty=format:"%H" -1); cd ../../../../
    cd bootloader/uboot-repo/bl31_1.3/bin/
    echo "bl31_1.3  : "$(git log --pretty=format:"%H" -1); cd ../../../../
    cd bootloader/uboot-repo/bl32_3.8/bin/
    echo "bl32_3.8  : "$(git log --pretty=format:"%H" -1); cd ../../../../
    cd bootloader/uboot-repo/bl33/v2019
    echo "bl33_v2019: "$(git log --pretty=format:"%H" -1); cd ../../../../
    cd bootloader/uboot-repo/fip/
    echo "fip       : "$(git log --pretty=format:"%H" -1); cd ../../../
    cd vendor/amlogic/common/tdk_v3/
    echo "tdk_v3    : "$(git log --pretty=format:"%H" -1); cd ../../../../
    cd vendor/amlogic/common/tdk_v3/ta_export
    echo "ta_export : "$(git log --pretty=format:"%H" -1); cd ../../../../../
    echo -e;
    echo "Verify:"; echo "no need verify"
}


# Main Function
########################################################################################################################################################################

if [ $# -gt 1 ] || [[ $# -eq 1 && $1 == "help" ]]; then
    usage
fi

if [ $# -eq 1 ]; then
    params=$1
    if [[ $params != "uboot" \
        && $params != "all-uboot" \
        && $params != "bootimage" \
        && $params != "kernel" \
        && $params != "logoimg" \
        && $params != "recoveryimage" \
        && $params != "systemimage" \
        && $params != "vendorimage" \
        && $params != "odm_image" \
        && $params != "dtbimage" \
        && $params != "build-modules-quick" ]]; then
        usage
    fi
fi

read_platform_type
read_android_type
get_project_path

if [ $# -eq 1 ]; then
    if [[ $params == "uboot" ]]; then
        compile_uboot
        print_uboot_info
        exit
    elif [[ $params == "all-uboot" ]]; then
        for platform_type in `seq ${#project[@]}`;do
            get_project_path
            compile_uboot
        done
        print_uboot_info
        exit
    fi
fi

source build/envsetup.sh

# DRM
if [ $uboot_drm_type -eq 2 ]; then
    export  BOARD_COMPILE_ATV=false
    export  BOARD_COMPILE_CTS=true
# GTVS
elif [ $uboot_drm_type -eq 3 ]; then
    if [ ! -d "vendor/google_gtvs" ];then
        echo "==========================================="
        echo "There is not Google GMS in vendor directory"
        echo "==========================================="
        exit
    fi
    export  BOARD_COMPILE_ATV=true
# AOSP
else
    export  BOARD_COMPILE_ATV=false
fi

if [[ ${module[platform_type]} == "planck" ]]; then
    export KERNEL_A32_SUPPORT=true
fi

kernel_project=${module[platform_type]}
project_name=${module[platform_type]}
if [[ ${module[platform_type]} == "ohm_mxl258c" ]]; then
    kernel_extra_tag="--fccpip"
    kernel_project="ohm"
elif [[ ${module[platform_type]} == "oppen_mxl258c" ]]; then
    kernel_extra_tag="--fccpip"
    kernel_project="oppen"
elif [[ ${module[platform_type]} == "oppencas_mxl258c" ]]; then
    kernel_extra_tag="--fccpip"
    kernel_project="oppencas"
elif [[ ${module[platform_type]} == "franklin_hybrid" ]]; then
    kernel_project="franklin"
fi
lunch "${project_name}-userdebug"
if [ $# -eq 1 ]; then
    if [ $1 == "bootimage" ]; then
        echo "make $1"
        ./mk ${kernel_project} -v 5.4 -t userdebug ${kernel_extra_tag}
        make bootimage
        make vendorbootimage
        exit
    elif [ $1 == "logoimg" ] \
    || [ $1 == "recoveryimage" ] \
    || [ $1 == "systemimage" ] \
    || [ $1 == "vendorimage" ] \
    || [ $1 == "odm_image" ] ; then
        echo "make $1"
        make $1 -j8
        exit
    elif  [ $1 == "kernel" ]; then
        ./mk ${kernel_project} -v 5.4 ${kernel_extra_tag}
        exit
    else
        usage
    fi
fi
compile_uboot
if [[ ${module[platform_type]} == "franklin" || ${module[platform_type]} == "franklin_hybrid" ]]; then
	./mk ${kernel_project} -v 4.9
else
	./mk ${kernel_project} -v 5.4 ${kernel_extra_tag}
fi

if [ $? != 0 ]; then echo " Error : Build Kernel error, exit!!!"; exit; fi

if [[ ${module[platform_type]} == "franklin" || ${module[platform_type]} == "franklin_hybrid" ]]; then
	make otapackage TARGET_BUILD_KERNEL_4_9=true -j16
else
	make otapackage -j8
fi
########################################################################################################################################################################

