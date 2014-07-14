#!/bin/sh
#
# Build installers and repo for Natron Linux64
# Written by Ole Andre Rodlie <olear@dracolinux.org>
#

SDK_VERSION=0.9
SNAPSHOT=20140706

DATE=$(date +%Y-%m-%d)
DATE_NUM=$(echo $DATE | sed 's/-//g')

CWD=$(pwd)
INSTALL_PATH=/opt/Natron-$SDK_VERSION
TMP_PATH=$CWD/tmp
export LD_LIBRARY_PATH=$INSTALL_PATH/lib

if [ ! -d $TMP_PATH ]; then
  mkdir -p $TMP_PATH || exit 1
else
  rm -rf $TMP_PATH || exit 1
  mkdir -p $TMP_PATH || exit 1
fi

# SETUP
INSTALLER=$TMP_PATH/Natron-installer
XML=$CWD/installer/xml
QS=$CWD/installer/qs

mkdir -p $INSTALLER/{config,packages} || exit 1
cat $CWD/installer/config/config.xml > $INSTALLER/config/config.xml || exit 1
cp $CWD/installer/config/*.png $INSTALLER/config/ || exit 1

# OFX YADIF
OFX_YADIF_VERSION=20140713
OFX_YADIF_PATH=$INSTALLER/packages/net.sf.ofx.yadif
mkdir -p $OFX_YADIF_PATH/{data,meta} $OFX_YADIF_PATH/data/Plugins $OFX_YADIF_PATH/data/docs/openfx-yadif || exit 1
cat $XML/openfx-yadif.xml | sed "s/_VERSION_/${OFX_YADIF_VERSION}/;s/_DATE_/${DATE}/" > $OFX_YADIF_PATH/meta/package.xml || exit 1
cat $QS/openfx-yadif.qs > $OFX_YADIF_PATH/meta/installscript.qs || exit 1
cp -a $INSTALL_PATH/docs/openfx-yadif $OFX_YADIF_PATH/data/docs/ || exit 1
cat $OFX_YADIF_PATH/data/docs/openfx-yadif/README.md > $OFX_YADIF_PATH/meta/license.txt || exit 1
cp -a $INSTALL_PATH/Plugins/yadif.ofx.bundle $OFX_YADIF_PATH/data/Plugins/ || exit 1
strip -s $OFX_YADIF_PATH/data/Plugins/*/*/*/*
mkdir -p $OFX_YADIF_PATH/data/lib || exit 1

OFX_DEPENDS=$(ldd $OFX_YADIF_PATH/data/Plugins/*/*/*/*|grep opt | awk '{print $3}')
for x in $OFX_DEPENDS; do
  cp -v $x $OFX_YADIF_PATH/data/lib/ || exit 1
done
strip -s $OFX_YADIF_PATH/data/lib/*

# OFX OpenCV
OFX_CV_VERSION=20140713
OFX_CV_PATH=$INSTALLER/packages/net.sf.ofx.opencv
mkdir -p $OFX_CV_PATH/{data,meta} $OFX_CV_PATH/data/Plugins $OFX_CV_PATH/data/docs/openfx-opencv || exit 1
cat $XML/openfx-opencv.xml | sed "s/_VERSION_/${OFX_CV_VERSION}/;s/_DATE_/${DATE}/" > $OFX_CV_PATH/meta/package.xml || exit 1
cat $QS/openfx-opencv.qs > $OFX_CV_PATH/meta/installscript.qs || exit 1
cp -a $INSTALL_PATH/docs/openfx-opencv $OFX_CV_PATH/data/docs/ || exit 1
cat $OFX_CV_PATH/data/docs/openfx-opencv/README > $OFX_CV_PATH/meta/license.txt || exit 1
cp -a $INSTALL_PATH/Plugins/{inpaint,segment}.ofx.bundle $OFX_CV_PATH/data/Plugins/ || exit 1
strip -s $OFX_CV_PATH/data/Plugins/*/*/*/*
mkdir -p $OFX_CV_PATH/data/lib || exit 1

OFX_DEPENDS=$(ldd $OFX_CV_PATH/data/Plugins/*/*/*/*|grep opt | awk '{print $3}')
for x in $OFX_DEPENDS; do
  cp -v $x $OFX_CV_PATH/data/lib/ || exit 1
done
strip -s $OFX_CV_PATH/data/lib/*
rm -f $OFX_CV_PATH/data/lib/libav*
rm -f $OFX_CV_PATH/data/lib/libI*
rm -f $OFX_CV_PATH/data/lib/libjp*
rm -f $OFX_CV_PATH/data/lib/libpng*
rm -f $OFX_CV_PATH/data/lib/libsw*
rm -f $OFX_CV_PATH/data/lib/libtif*
rm -f $OFX_CV_PATH/data/lib/libH*
cp -a $INSTALL_PATH/docs/opencv $OFX_CV_PATH/data/docs/ || exit 1
cat $INSTALL_PATH/docs/opencv/LICENSE > $OFX_CV_PATH/meta/opencv-license.txt || exit 1

chown root:root -R $INSTALLER/*
(cd $INSTALLER; find . -type d -name .git -exec rm -rf {} \;)

if [ ! -d $CWD/repo/Linux64 ]; then
  mkdir -p $CWD/repo/Linux64 || exit 1
fi

echo "Done!"

$INSTALL_PATH/bin/repogen -v --update-new-components -p $INSTALLER/packages -c $INSTALLER/config/config.xml $CWD/repo/Linux64 || exit 1
