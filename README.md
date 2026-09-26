Advantech Secure Boot and rootfs encryption for ARM systems

# Overview

Currently this repository includes three Yocto layers:

- [meta-secure-boot-nxp](meta-secure-boot-nxp/README.md): Secure Boot support for NXP i.MX devices (currently only NXP i.MX8/9). This is an implementation matching NXP's meta-secure-boot features for i.MX8 and i.MX9 families in their [reference design](https://github.com/nxp-imx-support/meta-nxp-security-reference-design), but with a different architecture to avoid build/cache issues, and allowing other layers to be composed on top. We use the same input variables in order to provide a direct replacement when using NXP i.MX SoCs.
- [meta-rootfs-enc-core](meta-rootfs-enc-core/README.md): root filesystem encryption for `meta-secure-boot-*` layers (core layer).
- [meta-rootfs-enc-nxp](meta-rootfs-enc-nxp/README.md): root filesystem encryption for the `meta-secure-boot-*` layers (HW-specific layer).

Future support for other SoC vendors will follow the pattern:

```
meta-secure-boot-[SOC]
meta-rootfs-enc-core
meta-rootfs-enc-[SOC]
```

# Compatibility

In 'meta-secure-boot-nxp', in order to keep functionality we include recipes for both the new NXP IMX signer and also for the legacy one. Rationale: 1) SPSDK is very slow signing big Linux images, 2) some SoCs, e.g., iMX8QXP, are not being currently covered with SPSDK, e.g., for signing with SGKs. Once the functionality and fixes get added to SPSDK, we'll switch to the new signer for NXP SoCs.

# Currently supported hardware

i.MX8 and i.MX9 NXP SoCs. Tested on Advantech modules.

# Yocto compatibility

Yocto 5.0 (scarthgap) to 6.0 (wrynose)

# i.MX integration example (following NXP's style)

```
# variables used for the build folders and the setup

export MACHINE=rom2820-ed93
export DISTRO=fsl-imx-xwayland

# install the 'repo' tool

RBIN=$HOME/.bin
mkdir -p "$RBIN"
curl https://storage.googleapis.com/git-repo-downloads/repo > "$RBIN/repo"
chmod a+x "$RBIN/repo"
export PATH=$PATH:$RBIN

# workspace folder

WORKSPACE=$HOME/yocto
mkdir -p "$WORKSPACE"
cd "$WORKSPACE"

YOCTO_REPO=https://github.com/Advantech-EECC/imx-manifest

# The YOCTO_MANIFEST and YOCTO_BRANCH values below target different Yocto
# releases. For best AHAB support, use Yocto >= 5.2 (walnascar or later)

## For Yocto 5.0 (scarthgap)
#YOCTO_MANIFEST=imx-6.6.52-2.2.2-adv-r1.xml
#YOCTO_BRANCH=imx-linux-scarthgap-adv
#
## For Yocto 5.1 (styhead)
#YOCTO_MANIFEST=imx-6.12.3-1.0.0-adv-r4.xml
#YOCTO_BRANCH=imx-linux-styhead-adv
#
## For Yocto 5.2 (walnascar)
#YOCTO_MANIFEST=imx-6.12.49-2.2.0-adv-r6.xml
#YOCTO_BRANCH=imx-linux-walnascar-adv
#
## For Yocto 5.3 (whinlatter)
#YOCTO_MANIFEST=imx-6.18.2-1.0.0-adv-r5.xml
#YOCTO_BRANCH=imx-linux-whinlatter-adv

# For Yocto 6.0 (wrynose)
YOCTO_MANIFEST=imx-6.18.20-2.0.0-adv-r2.xml
YOCTO_BRANCH=imx-linux-wrynose-adv

repo init -u "$YOCTO_REPO" -b "$YOCTO_BRANCH" -m "$YOCTO_MANIFEST"
repo sync

# bitbake environment setup (layers and local configuration)

export ENABLE_ROOTFS_ENCRYPTION=1
export FACTORY_KEYS_DIR=/opt/private/keys/factory
export OPT_RM_WORK=1
export SIG_TOOL_PATH=/opt/cst-4.0.1
export SIG_DATA_PATH=/opt/private/keys/nxp/ahab_ecc256_sha256_no_ca_flag
export SSTATE_DIR=/mnt/yocto/sstate-data
export BB_HASHSERVE_DB_DIR=$SSTATE_DIR
export DL_DIR=/mnt/yocto/downloads
export BB_ENV_PASSTHROUGH_ADDITIONS="$BB_ENV_PASSTHROUGH_ADDITIONS \
	SIG_TOOL_PATH SIG_DATA_PATH SSTATE_DIR DL_DIR BB_HASHSERVE_DB_DIR \
	FACTORY_KEYS_DIR"

# Accept NXP EULAs (sources/meta-imx/LICENSE.txt) and launch setup:

export EULA=1

source adv-imx-setup-release.sh -b build-$MACHINE

# bitbake build

bitbake core-image-minimal
bitbake imx-image-full
```

Trying with other i.MX-based machines:

- [E.g. from Advantech Modular BSP](https://github.com/Advantech-EECC/meta-modular-bsp-nxp/tree/wrynose/conf/machine): rom2620-ed91 rom2820-ed93 rom5620-db5901 (AHAB) ; rsb3720 rom5721-db5901 rom5722-db2510 (HABv4)
- [E.g. from NXP EVK](https://github.com/Freescale/meta-freescale/tree/master/conf/machine): imx8ulp-lpddr4-evk (AHAB) ; imx8mpevk (HABv4)

Observations:
- For e.g. HABv4 you may use RSA-SHA signature instead of ECC-SHA
- Some SoCs don't support signatures with CA enabled flag in the SRKs (check reference manual for each SoC)
- When using Secure Boot + rootfs-enc, we recommend using the CST signer in `SIG_TOOL_PATH`, as SPSDK, where supported (AHAB), should work, but will be very slow signing big Linux+initramfs images. If you need SPSDK, use `SIG_TOOL_PATH=/usr/local/bin` (assuming normal SPSDK installation)

# i.MX manual integration in other existing build systems

1) Add the layers:

```
meta-secure-boot-nxp
meta-rootfs-enc-core
meta-rootfs-enc-nxp
```
- Adding the `meta-secure-boot-nxp` layer will enable the Secure Boot build, enabling the SB bootloader and signing the bootloader and Linux (NXP i.MX)
- Adding the `meta-rootfs-enc-core` and `meta-rootfs-enc-nxp` layers will enable the rootfs encryption (NXP i.MX)

2) Set the signature and key paths, and add to the BitBake env passthrough:

```
export SIG_TOOL_PATH=/opt/cst-4.0.1
export SIG_DATA_PATH=/opt/private/keys/nxp/ahab_ecc256_sha256_no_ca_flag
export FACTORY_KEYS_DIR=/opt/private/keys/factory
export BB_ENV_PASSTHROUGH_ADDITIONS="$BB_ENV_PASSTHROUGH_ADDITIONS \
				SIG_TOOL_PATH SIG_DATA_PATH FACTORY_KEYS_DIR"
```

For HABv4 SoCs use e.g.,
```
export SIG_DATA_PATH=/opt/private/keys/nxp/hab4_rsa2048_sha256
```

# i.MX PKI generation

For preparing keys and certificates to be placed in the `SIG_DATA_PATH` directory, check details in [meta-secure-boot-nxp/README.md](meta-secure-boot-nxp/README.md)

# Generating factory key pair

Factory keys (`FACTORY_KEYS_DIR`) are used for signing the SHA256 file for the ext4 rootfs integrity, and also for HABv4 for signing the 'dtb' files.

To generate the key pair:

```
tools/gen-factory-signing-keys.sh
```

# Flashing images

E.g. writing to a memory card:

```
OUTPUT_WIC="$WORKSPACE/build-$MACHINE/tmp/deploy/images/$MACHINE/core-image-minimal-$MACHINE.rootfs.wic.zst"

bmaptool copy "$OUTPUT_WIC" /dev/mmcblk0
```

Using NXP's [UUU](https://github.com/nxp-imx/mfgtools/wiki/UUU) tool:

```
# Example for ROM-2820 (ROM-ED93 carrier), pre-requisites:
# - Set the boot mode to 'serial downloader'
# - Connect the USB OTG cable to the computer

uuu -b sd_all "$OUTPUT_WIC"
uuu -b emmc_all "$OUTPUT_WIC"
```

# Status and limitations

## i.MX on Yocto 5.0 (scarthgap)

Machines in this release:

- [Advantech Modular BSP](https://github.com/Advantech-EECC/meta-modular-bsp-nxp/tree/scarthgap/conf/machine)
- [NXP EVK/MEK](https://github.com/Freescale/meta-freescale/tree/scarthgap/conf/machine)

Secure Boot:

- Most Advantech AHAB and HABv4 machines work. Exceptions: ecu150a1 (work in progress)
- NXP EVKs tested: imx8ulp-lpddr4-evk (AHAB), imx8mpevk (HABv4)

Secure Boot + root filesystem encryption:

- Most Advantech HABv4 machines with operative Secure Boot should work.
- Advantech AHAB boards having issues: aom5521a2-db2510, rom2620-ed91, rom2820-ed93 (related to how `fdt_addr` is relocated in U-Boot instead of relying on the bootloader image, that got fixed in Yocto 5.2 (walnascar))
- NXP EVKs tested: imx8ulp-lpddr4-evk (AHAB), imx8mpevk (HABv4)

## i.MX on Yocto 5.1 (styhead)

Machines in this release:

- [Advantech Modular BSP](https://github.com/Advantech-EECC/meta-modular-bsp-nxp/tree/styhead/conf/machine)
- [NXP EVK/MEK](https://github.com/Freescale/meta-freescale/tree/styhead/conf/machine)

Secure Boot:

- Most Advantech AHAB and HABv4 machines work. Exceptions: ecu150a1 (work in progress)
- NXP EVKs tested: imx8ulp-lpddr4-evk (AHAB), imx8mpevk (HABv4)

Secure boot + root filesystem encryption:

- Same limitations as Yocto 5.0 (scarthgap), as the FDT address propagation for NXP got fixed in Yocto 5.2 (walnascar)
- NXP EVKs tested: imx8ulp-lpddr4-evk (AHAB), imx8mpevk (HABv4)

## i.MX on Yocto 5.2 (walnascar)

Machines in this release:

- [Advantech Modular BSP](https://github.com/Advantech-EECC/meta-modular-bsp-nxp/tree/walnascar/conf/machine)
- [NXP EVK/MEK](https://github.com/Freescale/meta-freescale/tree/walnascar/conf/machine)

Secure Boot:

- All Advantech AHAB and HABv4 machines should work, including ecu150a1
- NXP EVKs tested: imx8ulp-lpddr4-evk (AHAB), imx8mpevk (HABv4)

Secure boot + root filesystem encryption:

- Most Advantech AHAB and HABv4 machines should work. Exception: aom5521a2-db2510 (work in progress)
- NXP EVKs tested: imx8ulp-lpddr4-evk (AHAB), imx8mpevk (HABv4)

## i.MX on Yocto 5.3 (whinlatter)

Machines in this release:

- [Advantech Modular BSP](https://github.com/Advantech-EECC/meta-modular-bsp-nxp/tree/whinlatter/conf/machine)
- [NXP EVK/MEK](https://github.com/Freescale/meta-freescale/tree/whinlatter/conf/machine)

Secure Boot:

- Most Advantech AHAB and HABv4 machines should work. Exception: ecu150a1 (work in progress)
- NXP EVKs tested: imx8ulp-lpddr4-evk (AHAB), imx8mpevk (HABv4)

Secure boot + root filesystem encryption:

- Most Advantech AHAB and HABv4 machines with operative Secure Boot should work. Exception: aom5521a2-db2510 (work in progress)
- NXP EVKs tested: imx8ulp-lpddr4-evk (AHAB), imx8mpevk (HABv4)

## i.MX on Yocto 6.0 (wrynose)

Machines in this release:

- [Advantech Modular BSP](https://github.com/Advantech-EECC/meta-modular-bsp-nxp/tree/wrynose/conf/machine)
- [NXP EVK/MEK](https://github.com/Freescale/meta-freescale/tree/wrynose/conf/machine)

Secure Boot:

- Most Advantech AHAB and HABv4 machines should work. Exception: ecu150a1 (work in progress)
- NXP EVKs tested: imx8ulp-lpddr4-evk (AHAB), imx8mpevk (HABv4)

Secure boot + root filesystem encryption:

- Most Advantech AHAB and HABv4 machines with operative Secure Boot should work. Exceptions: aom5521a2-db2510 (work in progress), rom5620-db5901 (work in progress)
- NXP EVKs tested: imx8ulp-lpddr4-evk (AHAB), imx8mpevk (HABv4)
