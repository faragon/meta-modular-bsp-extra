#
# meta-rootfs-enc-nxp/recipes-security/optee/optee-os_%.imx.bbappend
#
# Fixes for i.MX9x (ELE OCRAM + TEE):
# - lf-6.6.52-2.2.2 (Yocto 5.0 scarthgap)
#   - CFG_IMX_TRUSTED_ARM_CE=y
# - lf-6.12.3-1.0.0 (Yocto 5.1 styhead)
#   - CFG_IMX_TRUSTED_ARM_CE=y and CFG_CORE_HEAP_SIZE=262144
# - For simplicity both configs have been added to all pre-walnascar
#
# Copyright (c) 1983-2026 Advantech Co., Ltd. All rights reserved.
#

inherit imx_rootfs_enc

EXTRA_OEMAKE:append:ele-ocram-tee:pre-walnascar = " \
    CFG_IMX_TRUSTED_ARM_CE=y \
    CFG_CORE_HEAP_SIZE=262144 \
"
