#!/bin/sh
#
# Build Natron for Linux64 (using CentOS 6.2)
# Written by Ole Andre Rodlie <olear@dracolinux.org>
#

RELEASE=WS
SDK_VERSION=0.9

DATE=$(date +%Y-%m-%d)
CWD=$(pwd)
INSTALL_PATH=/opt/Natron-$SDK_VERSION
TMP_PATH=$CWD/tmp
VERSION=$(cat $INSTALL_PATH/NATRON_VERSION)

if [ ! -d $TMP_PATH ]; then
  mkdir -p $TMP_PATH || exit 1
else
  rm -rf $TMP_PATH || exit 1
  mkdir -p $TMP_PATH || exit 1
fi

INSTALLER=$TMP_PATH/Natron-installer

mkdir -p $INSTALLER/config $INSTALLER/packages/fr.inria.natron.{io,misc}/{data,meta} $INSTALLER/packages/fr.inria.natron/{data,meta} || exit 1
mkdir -p $INSTALLER/packages/fr.inria.OpenColorConfigs/{data,meta} || exit 1
mkdir -p $INSTALLER/packages/fr.inria.OpenColorConfigs/data/share || exit 1

mkdir -p $INSTALLER/packages/fr.inria.natron.io/data/Plugins || exit 1
cp -a $INSTALL_PATH/Plugins/IO.ofx.bundle $INSTALLER/packages/fr.inria.natron.io/data/Plugins/ || exit 1

mkdir -p $INSTALLER/packages/fr.inria.natron.misc/data/Plugins || exit 1
cp -a $INSTALL_PATH/Plugins/Misc.ofx.bundle $INSTALLER/packages/fr.inria.natron.misc/data/Plugins/ || exit 1

INSTALLER_LIB=$INSTALLER/packages/fr.inria.natron/data/lib
INSTALLER_BIN=$INSTALLER/packages/fr.inria.natron/data/bin
INSTALLER_SHARE=$INSTALLER/packages/fr.inria.natron/data/share

mkdir -p $INSTALLER_LIB $INSTALLER_BIN $INSTALLER_SHARE/pixmaps || exit 1

cp $INSTALL_PATH/bin/Natron* $INSTALLER_BIN/ || exit 1
cp -a $INSTALL_PATH/share/OpenColorIO-Configs $INSTALLER/packages/fr.inria.OpenColorConfigs/data/share/ || exit 1
cp -a $INSTALL_PATH/plugins/{bearer,iconengines,imageformats,graphicssystems} $INSTALLER_BIN/ || exit 1
cp -a $INSTALL_PATH/docs $INSTALLER/packages/fr.inria.natron/data/ || exit 1
cp $INSTALL_PATH/share/pixmaps/natronIcon256_linux.png $INSTALLER_SHARE/pixmaps/ || exit 1

CORE_DEPENDS=$(ldd $INSTALLER_BIN/*|grep opt | awk '{print $3}')
for i in $CORE_DEPENDS; do
  cp -v $i $INSTALLER_LIB/ || exit 1
done

OFX_DEPENDS=$(ldd $INSTALLER/packages/*/data/Plugins/*/Contents/Linux-x86-64/*|grep opt | awk '{print $3}')
for x in $OFX_DEPENDS; do
  cp -v $x $INSTALLER_LIB/ || exit 1
done

LIB_DEPENDS=$(ldd $INSTALLER_LIB/*|grep opt | awk '{print $3}')
for y in $LIB_DEPENDS; do
  cp -v $y $INSTALLER_LIB/ || exit 1
done

PLUG_DEPENDS=$(ldd $INSTALLER_BIN/*/*|grep opt | awk '{print $3}')
for z in $PLUG_DEPENDS; do
  cp -v $z $INSTALLER_LIB/ || exit 1
done

tar xvf $CWD/installer/compat.tgz -C $INSTALLER_LIB/ || exit 1

strip -s $INSTALLER_BIN/*/*
strip -s $INSTALLER_BIN/*
strip -s $INSTALLER_LIB/*
strip -s $INSTALLER/packages/*/data/Plugins/*/Contents/Linux-x86-64/*

cat $CWD/installer/natron_installscript.qs > $INSTALLER/packages/fr.inria.natron/meta/installscript.qs || exit
cat $CWD/installer/installscript.qs > $INSTALLER/packages/fr.inria.natron.io/meta/installscript.qs || exit
cat $CWD/installer/installscript.qs > $INSTALLER/packages/fr.inria.natron.misc/meta/installscript.qs || exit
cat $CWD/installer/installscript.qs > $INSTALLER/packages/fr.inria.OpenColorConfigs/meta/installscript.qs || exit

cat $CWD/installer/natron_package.xml | sed "s/_VERSION_/0.9/;s/_DATE_/${DATE}/" > $INSTALLER/packages/fr.inria.natron/meta/package.xml || exit 1
cat $CWD/installer/ofx_package.xml | sed "s/_VERSION_/${DATE}/;s/_DATE_/${DATE}/;s/_NAME_/OpenFX IO Plugin/;s/_DOMAIN_/fr.inria.natron.io/" > $INSTALLER/packages/fr.inria.natron.io/meta/package.xml || exit 1
cat $CWD/installer/ofx_package.xml | sed "s/_VERSION_/${DATE}/;s/_DATE_/${DATE}/;s/_NAME_/OpenFX Misc Plugins/;s/_DOMAIN_/fr.inria.natron.misc/" > $INSTALLER/packages/fr.inria.natron.misc/meta/package.xml || exit 1
cat $CWD/installer/color_package.xml | sed "s/_VERSION_/${DATE}/;s/_DATE_/${DATE}/" > $INSTALLER/packages/fr.inria.OpenColorConfigs/meta/package.xml || exit 1

mkdir -p $INSTALLER/packages/fr.inria.natron.io/data/docs || exit 1
mv $INSTALLER/packages/fr.inria.natron/data/docs/openfx-io $INSTALLER/packages/fr.inria.natron.io/data/docs/ || exit 1

mkdir -p $INSTALLER/packages/fr.inria.natron.misc/data/docs || exit 1
mv $INSTALLER/packages/fr.inria.natron/data/docs/openfx-misc $INSTALLER/packages/fr.inria.natron.misc/data/docs/ || exit 1

cp -a $CWD/installer/config/* $INSTALLER/config/ || exit 1
cat $CWD/installer/config/config.xml | sed "s/_VERSION_/0.9/" > $INSTALLER/config/config.xml || exit 1

cat $CWD/installer/Natron.sh > $INSTALLER/packages/fr.inria.natron/data/Natron || exit 1
cat $CWD/installer/Natron.sh | sed "s#bin/Natron#bin/NatronRenderer#" > $INSTALLER/packages/fr.inria.natron/data/NatronRenderer || exit 1
chmod +x $INSTALLER/packages/fr.inria.natron/data/Natron* || exit 1

cp $INSTALLER/packages/fr.inria.natron/data/docs/natron/LICENSE.txt $INSTALLER/packages/fr.inria.natron/meta/license.txt || exit 1

binarycreator -v -f -p $INSTALLER/packages -c $INSTALLER/config/config.xml $CWD/Natron-$VERSION-setup-linux64.bin || exit 1
sha1sum $CWD/Natron-$VERSION-setup-linux64.bin > $CWD/Natron-$VERSION-setup-linux64.sha1 || exit 1

#build-installer.sh  compat.tgz  config  installscript.qs  natron  natron_installscript.qs  natron_package.xml  ofx_packages.xml  packages

#chown root:root -R *
#find . -type d -name .git -exec rm -rf {} \;

#cd .. || exit 1
#tar cvvzf Natron-$VERSION-$RELEASE-linux64.tgz Natron-$VERSION-$RELEASE-linux64 || exit 1
