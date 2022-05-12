#!/bin/sh
#execute this shell when you sync device/khadas/common/gpu from Pie or lower
sed -i 's/BOARD_VENDOR_KERNEL_MODULES +=/DEFAULT_GPU_KERNEL_MODULES :=/g' *.mk
