Advantech Secure Boot Yocto layer for NXP i.MX systems

# Overview

This layer provides Secure Boot support for boards using NXP iMX SoCs (i.MX 8 and i.MX 9 families).

Tested on Advantech hardware. NXP EVKs and other vendor boards may work too.

The approach we follow is extending bootloader and Linux recipes, adding the signature for the bootloader and the Linux image.

Layout:

```
.
├── classes
│   ├── imx_boot_tools.bbclass
│   ├── imx_signer.bbclass
│   ├── imx_signer_common.bbclass
│   └── secure_boot.bbclass
├── conf
│   └── layer.conf
├── README.md
├── recipes-bsp
│   ├── imx-mkimage
│   │   ├── files
│   │   │   └── 0001-imx-mkimage-ahab-unhardwiring.patch
│   │   └── imx-boot_%.bbappend
│   └── u-boot
│       ├── u-boot-imx
│       │   └── common
│       │       ├── ahab_boot.cfg
│       │       └── hab4_boot.cfg
│       └── u-boot-imx_%.bbappend
├── recipes-core
│   └── images
│       ├── common.inc
│       ├── core-image-base.bbappend -> common.inc
│       ├── core-image-minimal.bbappend -> common.inc
│       ├── core-image-sato.bbappend -> common.inc
│       ├── fsl-image-machine-test.bbappend -> common.inc
│       ├── imx-image-core.bbappend -> common.inc
│       ├── imx-image-full.bbappend -> common.inc
│       └── imx-image-multimedia.bbappend -> common.inc
├── recipes-kernel
│   └── linux
│       └── linux-imx_%.bbappend
└── recipes-security
    ├── nxp-cst-signer-legacy
    │   └── nxp-cst-signer-legacy.bb
    └── nxp-imx-signer
        └── nxp-imx-signer.bb
```

# Drop-in replacement for NXP's meta-secure-boot

We designed intentionally this layer to be simple to use as a drop-in replacement for NXP's [meta-secure-boot reference design](https://github.com/nxp-imx-support/meta-nxp-security-reference-design) by replacing meta-secure-boot with meta-secure-boot-nxp. In order to facilitate the migration and/or interoperability we have:

- Target `meta-secure-boot-nxp` instead of `meta-secure-boot`
- Use same input variable names (`SIG_TOOL_PATH` and `SIG_DATA_PATH`)


# i.MX PKI generation

For generating keys and certificates to be placed in `SIG_DATA_PATH`, we recommend using the guides provided by NXP, as they also explain how to program the SRK fuses and close the device.

Reference:

- [i.MX8X, i.MX8ULP, i.MX9x (AHAB)](https://github.com/nxp-imx/uboot-imx/tree/lf_v2024.04/doc/imx/ahab/guides)
- [i.MX8M (HABv4)](https://github.com/nxp-imx/uboot-imx/tree/lf_v2024.04/doc/imx/habv4/guides)

E.g. for HABv4 RSA-2048 SHA-256 w/CA-flag enabled (using CSF configuration for CST backend):

```
.
├── crts
│   ├── CA1_sha256_2048_65537_v3_ca_crt.der
│   ├── CA1_sha256_2048_65537_v3_ca_crt.pem
│   ├── CSF1_1_sha256_2048_65537_v3_usr_crt.der
│   ├── CSF1_1_sha256_2048_65537_v3_usr_crt.pem
│   ├── CSF2_1_sha256_2048_65537_v3_usr_crt.der
│   ├── CSF2_1_sha256_2048_65537_v3_usr_crt.pem
│   ├── CSF3_1_sha256_2048_65537_v3_usr_crt.der
│   ├── CSF3_1_sha256_2048_65537_v3_usr_crt.pem
│   ├── CSF4_1_sha256_2048_65537_v3_usr_crt.der
│   ├── CSF4_1_sha256_2048_65537_v3_usr_crt.pem
│   ├── IMG1_1_sha256_2048_65537_v3_usr_crt.der
│   ├── IMG1_1_sha256_2048_65537_v3_usr_crt.pem
│   ├── IMG2_1_sha256_2048_65537_v3_usr_crt.der
│   ├── IMG2_1_sha256_2048_65537_v3_usr_crt.pem
│   ├── IMG3_1_sha256_2048_65537_v3_usr_crt.der
│   ├── IMG3_1_sha256_2048_65537_v3_usr_crt.pem
│   ├── IMG4_1_sha256_2048_65537_v3_usr_crt.der
│   ├── IMG4_1_sha256_2048_65537_v3_usr_crt.pem
│   ├── SRK_1_2_3_4_fuse.bin
│   ├── SRK_1_2_3_4_table.bin
│   ├── SRK1_sha256_2048_65537_v3_ca_crt.der
│   ├── SRK1_sha256_2048_65537_v3_ca_crt.pem
│   ├── SRK2_sha256_2048_65537_v3_ca_crt.der
│   ├── SRK2_sha256_2048_65537_v3_ca_crt.pem
│   ├── SRK3_sha256_2048_65537_v3_ca_crt.der
│   ├── SRK3_sha256_2048_65537_v3_ca_crt.pem
│   ├── SRK4_sha256_2048_65537_v3_ca_crt.der
│   └── SRK4_sha256_2048_65537_v3_ca_crt.pem
├── csf_hab4.cfg
└── keys
    ├── CA1_sha256_2048_65537_v3_ca_key.der
    ├── CA1_sha256_2048_65537_v3_ca_key.pem
    ├── CSF1_1_sha256_2048_65537_v3_usr_key.der
    ├── CSF1_1_sha256_2048_65537_v3_usr_key.pem
    ├── CSF2_1_sha256_2048_65537_v3_usr_key.der
    ├── CSF2_1_sha256_2048_65537_v3_usr_key.pem
    ├── CSF3_1_sha256_2048_65537_v3_usr_key.der
    ├── CSF3_1_sha256_2048_65537_v3_usr_key.pem
    ├── CSF4_1_sha256_2048_65537_v3_usr_key.der
    ├── CSF4_1_sha256_2048_65537_v3_usr_key.pem
    ├── IMG1_1_sha256_2048_65537_v3_usr_key.der
    ├── IMG1_1_sha256_2048_65537_v3_usr_key.pem
    ├── IMG2_1_sha256_2048_65537_v3_usr_key.der
    ├── IMG2_1_sha256_2048_65537_v3_usr_key.pem
    ├── IMG3_1_sha256_2048_65537_v3_usr_key.der
    ├── IMG3_1_sha256_2048_65537_v3_usr_key.pem
    ├── IMG4_1_sha256_2048_65537_v3_usr_key.der
    ├── IMG4_1_sha256_2048_65537_v3_usr_key.pem
    ├── index.txt
    ├── index.txt.attr
    ├── key_pass.txt
    ├── serial
    ├── SRK1_sha256_2048_65537_v3_ca_key.der
    ├── SRK1_sha256_2048_65537_v3_ca_key.pem
    ├── SRK2_sha256_2048_65537_v3_ca_key.der
    ├── SRK2_sha256_2048_65537_v3_ca_key.pem
    ├── SRK3_sha256_2048_65537_v3_ca_key.der
    ├── SRK3_sha256_2048_65537_v3_ca_key.pem
    ├── SRK4_sha256_2048_65537_v3_ca_key.der
    └── SRK4_sha256_2048_65537_v3_ca_key.pem
```

E.g. for AHAB ECC-256 SHA256 with SRKs without CA flag enabled (CSF and YAML configurations for CST and SPSDK backends):

```
.
├── crts
│   ├── CA1_sha256_secp256r1_v3_ca_crt.der
│   ├── CA1_sha256_secp256r1_v3_ca_crt.pem
│   ├── SRK_1_2_3_4_fuse.bin
│   ├── SRK_1_2_3_4_table.bin
│   ├── SRK1_sha256_secp256r1_v3_usr_crt.der
│   ├── SRK1_sha256_secp256r1_v3_usr_crt.pem
│   ├── SRK2_sha256_secp256r1_v3_usr_crt.der
│   ├── SRK2_sha256_secp256r1_v3_usr_crt.pem
│   ├── SRK3_sha256_secp256r1_v3_usr_crt.der
│   ├── SRK3_sha256_secp256r1_v3_usr_crt.pem
│   ├── SRK4_sha256_secp256r1_v3_usr_crt.der
│   └── SRK4_sha256_secp256r1_v3_usr_crt.pem
├── csf_ahab.cfg
├── keys
│   ├── CA1_sha256_secp256r1_v3_ca_key.der
│   ├── CA1_sha256_secp256r1_v3_ca_key.pem
│   ├── index.txt
│   ├── index.txt.attr
│   ├── key_pass.txt
│   ├── serial
│   ├── SRK1_sha256_secp256r1_v3_usr_key.der
│   ├── SRK1_sha256_secp256r1_v3_usr_key.pem
│   ├── SRK2_sha256_secp256r1_v3_usr_key.der
│   ├── SRK2_sha256_secp256r1_v3_usr_key.pem
│   ├── SRK3_sha256_secp256r1_v3_usr_key.der
│   ├── SRK3_sha256_secp256r1_v3_usr_key.pem
│   ├── SRK4_sha256_secp256r1_v3_usr_key.der
│   └── SRK4_sha256_secp256r1_v3_usr_key.pem
└── spsdk_ahab.yaml
```

# i.MX signature backend configuration examples

For the PKI examples shown before, here we add their configurations.

For selecting the CST backend (AHAB and HABv4):

- `SIG_TOOL_PATH=/opt/cst-4.0.1`

For selecting the SPSDK backend (AHAB-only):

- `SIG_TOOL_PATH=/usr/local/bin` (default 'spsdk' installation)

## i.MX AHAB `csf_ahab.cfg` configuration example (CST backend)

```
#Header
header_version=1.0
#Install SRK
srktable_file=SRK_1_2_3_4_table.bin
srk_source=SRK1_sha256_secp256r1_v3_usr_crt.pem
srk_source_index=0
srk_source_set=OEM
srk_revocations=0x0
```

## i.MX AHAB `spsdk_ahab.yaml` configuration example (SPSDK backend)

```
family: automatic          # This gets rewritten by meta-secure-boot-nxp, in the same way NXP's meta-secure-boot does
revision: latest
srk_set: oem
used_srk_id: 0             # 0 = SRK1, 1 = SRK2, 2 = SRK3, 3 = SRK4
srk_revoke_mask: 0         # 0 = no keys revoked
signer: SRK1_sha256_secp256r1_v3_usr_key.pem
srk_table:
  flag_ca: false
  hash_algorithm: sha256
  srk_array:
    - SRK1_sha256_secp256r1_v3_usr_crt.pem
    - SRK2_sha256_secp256r1_v3_usr_crt.pem
    - SRK3_sha256_secp256r1_v3_usr_crt.pem
    - SRK4_sha256_secp256r1_v3_usr_crt.pem
```

## i.MX HABv4 `csf_hab4.cfg` configuration example (CST backend)

```
#Header
header_version=4.3
header_eng=ANY
header_eng_config=0
#Install SRK
srktable_file=SRK_1_2_3_4_table.bin
# srk_source_index: 0..3 for selecting the key (SRK1, SRK2, SRK3, SRK4)
srk_source_index=0
#Install NOCAK
nocak_file=
#Install CSFK: CSF1_1_* for SRK1, CSF2_1_* for SRK2, etc.
csfk_file=CSF1_1_sha256_2048_65537_v3_usr_crt.pem
#Authenticate CSF
#Unlock
unlock_engine=CAAM
unlock_features=MID,RNG
unlock_uid=
#Install Key
img_verification_index=0
img_target_index=2
#Use IMG1_1_* for SRK1, IMG2_1_* for SRK2, etc.
img_file=IMG1_1_sha256_2048_65537_v3_usr_crt.pem
#Authenticate Data
auth_verification_index=2
```
