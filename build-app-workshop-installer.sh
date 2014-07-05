#!/bin/sh
#
# Written by Ole Andre Rodlie <olear@dracolinux.org>
#

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

mkdir -p $INSTALLER/config $INSTALLER/packages/fr.inria.Natron{IO,Misc,Core,Renderer}/{data,meta} $INSTALLER/packages/fr.inria.Natron/{data,meta} || exit 1
mkdir -p $INSTALLER/packages/fr.inria.OpenColorConfigs/{data,meta} || exit 1
mkdir -p $INSTALLER/packages/fr.inria.OpenColorConfigs/data/share || exit 1

mkdir -p $INSTALLER/packages/fr.inria.NatronIO/data/Plugins || exit 1
cp -a $INSTALL_PATH/Plugins/IO.ofx.bundle $INSTALLER/packages/fr.inria.NatronIO/data/Plugins/ || exit 1

mkdir -p $INSTALLER/packages/fr.inria.NatronMisc/data/Plugins || exit 1
cp -a $INSTALL_PATH/Plugins/Misc.ofx.bundle $INSTALLER/packages/fr.inria.NatronMisc/data/Plugins/ || exit 1

mkdir -p $INSTALLER/packages/fr.inria.Natron{Core,Renderer}/data/bin $INSTALLER/packages/fr.inria.NatronCore/data/{docs,lib} || exit 1

INSTALLER_LIB=$INSTALLER/packages/fr.inria.NatronCore/data/lib
INSTALLER_BIN=$INSTALLER/packages/fr.inria.Natron/data/bin
INSTALLER_SHARE=$INSTALLER/packages/fr.inria.Natron/data/share

mkdir -p $INSTALLER_LIB $INSTALLER_BIN $INSTALLER_SHARE/pixmaps $INSTALLER/packages/fr.inria.Natron/data/docs || exit 1

echo ja
cp $INSTALL_PATH/bin/Natron $INSTALLER_BIN/ || exit 1
cp $INSTALL_PATH/bin/NatronRenderer $INSTALLER/packages/fr.inria.NatronRenderer/data/bin/ || exit 1
cp -a $INSTALL_PATH/share/OpenColorIO-Configs $INSTALLER/packages/fr.inria.OpenColorConfigs/data/share/ || exit 1
cp -a $INSTALL_PATH/plugins/{bearer,iconengines,imageformats,graphicssystems} $INSTALLER/packages/fr.inria.NatronCore/data/bin/ || exit 1
cp -a $INSTALL_PATH/docs/natron $INSTALLER/packages/fr.inria.Natron/data/docs || exit 1
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

PLUG_DEPENDS=$(ldd $INSTALLER/packages/fr.inria.NatronCore/data/*/*|grep opt | awk '{print $3}')
for z in $PLUG_DEPENDS; do
  cp -v $z $INSTALLER_LIB/ || exit 1
done

tar xvf $CWD/installer/compat.tgz -C $INSTALLER_LIB/ || exit 1

strip -s $INSTALLER_BIN/*/*
strip -s $INSTALLER_BIN/*
strip -s $INSTALLER_LIB/*
strip -s $INSTALLER/packages/*/data/Plugins/*/Contents/Linux-x86-64/*

cat $CWD/installer/natron_installscript.qs > $INSTALLER/packages/fr.inria.Natron/meta/installscript.qs || exit
cat $CWD/installer/installscript.qs > $INSTALLER/packages/fr.inria.NatronRenderer/meta/installscript.qs || exit
cat $CWD/installer/installscript.qs > $INSTALLER/packages/fr.inria.NatronCore/meta/installscript.qs || exit
cat $CWD/installer/installscript.qs > $INSTALLER/packages/fr.inria.NatronIO/meta/installscript.qs || exit
cat $CWD/installer/installscript.qs > $INSTALLER/packages/fr.inria.NatronMisc/meta/installscript.qs || exit
cat $CWD/installer/installscript.qs > $INSTALLER/packages/fr.inria.OpenColorConfigs/meta/installscript.qs || exit

DATE_VERSION=$(echo $DATE | sed 's/-/./g')

cat $CWD/installer/renderer_package.xml | sed "s/_VERSION_/${DATE_VERSION}/;s/_DATE_/${DATE}/" > $INSTALLER/packages/fr.inria.NatronRenderer/meta/package.xml || exit 1
cat $CWD/installer/natron_package.xml | sed "s/_VERSION_/${DATE_VERSION}/;s/_DATE_/${DATE}/" > $INSTALLER/packages/fr.inria.Natron/meta/package.xml || exit 1
cat $CWD/installer/package.xml | sed "s/_VERSION_/${DATE_VERSION}/;s/_DATE_/${DATE}/;s/_NAME_/Natron IO Plugins/;s/_DESC_/Natron Read and Write OFX Plugins/;s/_DOMAIN_/fr.inria.NatronIO/" > $INSTALLER/packages/fr.inria.NatronIO/meta/package.xml || exit 1
cat $CWD/installer/package.xml | sed "s/_VERSION_/${DATE_VERSION}/;s/_DATE_/${DATE}/;s/_NAME_/Natron Misc Plugins/;s/_DESC_/Natron Misc Image Plugins/;s/_DOMAIN_/fr.inria.NatronMisc/" > $INSTALLER/packages/fr.inria.NatronMisc/meta/package.xml || exit 1
cat $CWD/installer/color_package.xml | sed "s/_VERSION_/${DATE_VERSION}/;s/_DATE_/${DATE}/" > $INSTALLER/packages/fr.inria.OpenColorConfigs/meta/package.xml || exit 1

mkdir -p $INSTALLER/packages/fr.inria.NatronIO/data/docs || exit 1
cp -a $INSTALL_PATH/docs/openfx-io $INSTALLER/packages/fr.inria.NatronIO/data/docs/ || exit 1

mkdir -p $INSTALLER/packages/fr.inria.NatronMisc/data/docs || exit 1
cp -a $INSTALL_PATH/docs/openfx-misc $INSTALLER/packages/fr.inria.NatronMisc/data/docs/ || exit 1

cp -a $CWD/installer/config/* $INSTALLER/config/ || exit 1
cat $CWD/installer/config/config-workshop.xml | sed "s/_VERSION_/${DATE_VERSION}/" > $INSTALLER/config/config.xml || exit 1

cat $CWD/installer/Natron.sh > $INSTALLER/packages/fr.inria.Natron/data/Natron || exit 1
cat $CWD/installer/Natron.sh | sed "s#bin/Natron#bin/NatronRenderer#" > $INSTALLER/packages/fr.inria.NatronRenderer/data/NatronRenderer || exit 1
chmod +x $INSTALLER/packages/fr.inria.Natron/data/Natron $INSTALLER/packages/fr.inria.NatronRenderer/data/NatronRenderer || exit 1

cp $INSTALLER/packages/fr.inria.Natron/data/docs/natron/LICENSE.txt $INSTALLER/packages/fr.inria.Natron/meta/license.txt || exit 1

cat $INSTALLER/packages/*/meta/*.xml
cat $INSTALLER/config/*.xml

exit 0

if [ ! -d $CWD/repo ]; then
  mkdir -p $CWD/repo || exit 1
fi

repogen -v --update -p $INSTALLER/packages -c $INSTALLER/config/config.xml $CWD/repo || exit 1
binarycreator -v -f -p $INSTALLER/packages -c $INSTALLER/config/config.xml $CWD/Natron-$VERSION-install-linux64.bin || exit 1
binarycreator -n -v -p $INSTALLER/packages -c $INSTALLER/config/config.xml $CWD/Natron-workshop-online-linux64.bin || exit 1

#sha1sum $CWD/Natron-$VERSION-setup-linux64.bin > $CWD/Natron-$VERSION-setup-linux64.sha1 || exit 1

#chown root:root -R *
#find . -type d -name .git -exec rm -rf {} \;
