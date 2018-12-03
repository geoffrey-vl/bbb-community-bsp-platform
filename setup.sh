#!/bin/bash

REPODIR=${PWD}

echo $REPODIR

source sources/poky/oe-init-build-env build

# replace content of the bblayers.conf
cat <<EOF > conf/bblayers.conf
# POKY_BBLAYERS_CONF_VERSION is increased each time build/conf/bblayers.conf
# changes incompatibly
POKY_BBLAYERS_CONF_VERSION = "2"

BBPATH = "\${TOPDIR}"
BBFILES ?= ""

BBLAYERS ?= " \\
    ${REPODIR}/sources/poky/meta \\
    ${REPODIR}/sources/poky/meta-poky \\
    ${REPODIR}/sources/meta-openembedded/meta-oe \\
    ${REPODIR}/sources/meta-openembedded/meta-multimedia \\
    ${REPODIR}/sources/meta-openembedded/meta-networking \\
    ${REPODIR}/sources/meta-openembedded/meta-perl \\
    ${REPODIR}/sources/meta-openembedded/meta-python \\
    ${REPODIR}/sources/meta-qt5 \\
    ${REPODIR}/sources/meta-bbb \\
    ${REPODIR}/sources/meta-security \\
"
EOF

# create local.conf
cp ../sources/meta-bbb/conf/local.conf.sample conf/local.conf
# replace root's password into 'password'
sed -i -e 's/jumpnowtek/password/g' conf/local.conf
# add sdcard
echo  'IMAGE_FSTYPES+="sdcard"' >> conf/local.conf