#
# meta-rootfs-enc-nxp/recipes-kernel/linux/linux-imx_6.%.bbappend
#
# Expand base linux-imx for supporting rootfs encryption
#
# Observations:
# - Support for HABv4+CAAM, AHAB+CAAM, AHAB+EdgeLock
# - We rely on the initramfs Linux image for handling the rootfs encryption
#
# Copyright (c) 1983-2026 Advantech Co., Ltd. All rights reserved.
#

inherit imx_rootfs_enc

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:${THISDIR}/${PN}/common:"

require recipes-kernel/linux/linux-imx/common/enc-configs.inc

INITRAMFS_IMAGE = "rootfs-enc-image-initramfs"
INITRAMFS_IMAGE_BUNDLE = "1"

do_bundle_initramfs[depends] += "${INITRAMFS_IMAGE}:do_image_complete"

# For AHAB the signature is done in imx-boot, and not in linux-imx
HAB4_KERNEL_IMAGE = "${DEPLOYDIR}/${KERNEL_IMAGETYPE}-initramfs-${MACHINE}.bin"
