#
# meta-secure-boot-nxp/classes/secure_boot.bbclass
#
# The purpose of this file is defining HW-related information. Initially
# we cover NXP i.MX systems, adding more systems as needed.
#
# This follows the ideas of NXP's reference design ([1]), and offers
# drop-in replacement compatibility by using same signature-related
# input variables.
#
# [1] https://github.com/nxp-imx-support/meta-nxp-security-reference-design/blob/walnascar-6.12.49-2.2.0/meta-secure-boot-nxp/classes/xhab.bbclass
#
# Copyright (c) 1983-2026 Advantech Co., Ltd. All rights reserved.
#

do_configure[vardeps] += "SIG_TOOL_PATH SIG_DATA_PATH"
do_configure[file-checksums] += "${SIG_TOOL_PATH}:True ${SIG_DATA_PATH}:True"

UBOOT_BB ?= ""
UBOOT_BB:imx-nxp-bsp = "u-boot-imx"
TGT_BOOT_BB ?= ""
TGT_BOOT_BB:imx-nxp-bsp = "imx-boot"

OVERRIDES:append:mx8m-generic-bsp = ":caam"
OVERRIDES:append:mx8ulp-generic-bsp = ":caam:ele"
OVERRIDES:append:mx8qm-generic-bsp = ":caam"
OVERRIDES:append:mx8x-generic-bsp = ":caam"
OVERRIDES:append:mx9-generic-bsp = ":ele:ele-ocram-tee"

OVERRIDES:append:mx8m-generic-bsp = ":hab4"
OVERRIDES:append:mx8ulp-generic-bsp = ":ahab"
OVERRIDES:append:mx8qm-generic-bsp = ":ahab"
OVERRIDES:append:mx8x-generic-bsp = ":ahab"
OVERRIDES:append:mx9-generic-bsp = ":ahab"

SIGNED_TARGET:mx8m-generic-bsp = "flash_evk"
SIGNED_TARGET:mx8mnul-generic-bsp = "${IMXBOOT_TARGETS_BASENAME}"
SIGNED_TARGET:mx8x-generic-bsp = "${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'flash_spl', 'flash', d)}"
SIGNED_TARGET:mx8qm-generic-bsp = "flash_spl"
SIGNED_TARGET:mx8ulp-generic-bsp = "flash_singleboot_m33"
SIGNED_TARGET:mx91-generic-bsp = "flash_singleboot"
SIGNED_TARGET:mx93-generic-bsp = "flash_singleboot"
SIGNED_TARGET:mx943-generic-bsp = "flash_all"
SIGNED_TARGET:mx95-generic-bsp = "flash_all"
SIGNED_TARGET:mx952-generic-bsp = "flash_all"

SPSDK_FAMILY:mx8qm-generic-bsp = "mimx8qm"
SPSDK_FAMILY:mx8qxp-generic-bsp = "mimx8qxp"
SPSDK_FAMILY:mx8dxl-generic-bsp = "mimx8dxl"
SPSDK_FAMILY:mx8ulp-generic-bsp = "mimx8ulp"
SPSDK_FAMILY:mx91-generic-bsp = "mimx9131"
SPSDK_FAMILY:mx93-generic-bsp = "mimx9352"
SPSDK_FAMILY:mx943-generic-bsp = "mimx943"
SPSDK_FAMILY:mx95-generic-bsp = "mimx9596"
SPSDK_FAMILY:mx952-generic-bsp = "mimx95294"

CONFIG_SYS_LOAD_ADDR ?= "0"
CONFIG_SYS_LOAD_ADDR:mx8m-generic-bsp = "0x40400000"
CONFIG_SYS_LOAD_ADDR:mx8x-generic-bsp = "0x80200000"
CONFIG_SYS_LOAD_ADDR:mx8qm-generic-bsp = "0x80200000"
CONFIG_SYS_LOAD_ADDR:mx8ulp-nxp-bsp = "0x80400000"
CONFIG_SYS_LOAD_ADDR:mx91-nxp-bsp = "0x80400000"
CONFIG_SYS_LOAD_ADDR:mx93-nxp-bsp = "0x80400000"
CONFIG_SYS_LOAD_ADDR:mx943-nxp-bsp = "0x90400000"
CONFIG_SYS_LOAD_ADDR:mx95-nxp-bsp = "0x90400000"

# i.MX8/9: 8MiB of space before the first partition
PREPART_SIZE_KIB ?= "8192"
PREPART_SIZE_KIB:mx8-generic-bsp = "8192"
PREPART_SIZE_KIB:mx9-generic-bsp = "8192"

AHAB_OS_CNTR_SIGNED = "os_cntr_signed.bin"

# If a machine is not defining the DT base name, e..g. imx8qmmek,
# we'll assume is the same as the machine name
KERNEL_DEVICETREE_BASENAME ?= "${MACHINE}"

# Default: 64MiB max kernel image (fdt_addr comes after that)
# (left as '' for non-covered cases, so we can raise an error in imx-boot)
KERNEL_DTB_ADDR ?= "${@hex(int(d.getVar('CONFIG_SYS_LOAD_ADDR'), 0) + 67108864) if int(d.getVar('CONFIG_SYS_LOAD_ADDR'), 0) != 0 else ''}"
KERNEL_DTB ?= "${@os.path.basename(d.getVar('KERNEL_DEVICETREE_BASENAME'))}.dtb"

OVERRIDES:append = "${@':wrynose-or-newer' if bb.utils.vercmp_string(bb.__version__, '2.18') >= 0 else ':pre-wrynose'}"
OVERRIDES:append = "${@':whinlatter-or-newer' if bb.utils.vercmp_string(bb.__version__, '2.16') >= 0 else ':pre-whinlatter'}"
OVERRIDES:append = "${@':walnascar-or-newer' if bb.utils.vercmp_string(bb.__version__, '2.12') >= 0 else ':pre-walnascar'}"
OVERRIDES:append = "${@':styhead-or-newer' if bb.utils.vercmp_string(bb.__version__, '2.9') >= 0 else ':pre-styhead'}"
OVERRIDES:append = "${@':scarthgap-or-newer' if bb.utils.vercmp_string(bb.__version__, '2.8') >= 0 else ':pre-scarthgap'}"

# Encryption engine selection, e.g. for using in the meta-rootfs-enc layer
# Pick CAAM as encryption engine when both CAAM and ELE are present
python __anonymous() {
    overrides = set((d.getVar("OVERRIDES") or "").split(":"))
    if "caam" in overrides:
        d.appendVar("MACHINEOVERRIDES", ":ee_caam")
    elif "ele" in overrides:
        d.appendVar("MACHINEOVERRIDES", ":ee_ele")
}
