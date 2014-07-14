#!/bin/sh
#
# Build installers and repo for Natron Linux64
# Written by Ole Andre Rodlie <olear@dracolinux.org>
#

SDK_VERSION=0.9
SNAPSHOT=0.8.0.2

DATE=$(date +%Y-%m-%d)
DATE_NUM=$(echo $DATE | sed 's/-//g')

CWD=$(pwd)
INSTALL_PATH=/opt/Natron-$SDK_VERSION
TMP_PATH=$CWD/tmp

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

export LD_LIBRARY_PATH=$INSTALL_PATH/lib

mkdir -p $INSTALLER/{config,packages} || exit 1
cat $CWD/installer/config/config.xml > $INSTALLER/config/config.xml || exit 1
cp $CWD/installer/config/*.png $INSTALLER/config/ || exit 1

# OFX TUTTLE
TUTTLE_VERSION=$SNAPSHOT
TUTTLE_PATH=$INSTALLER/packages/org.tuttleofx.plugins
mkdir -p $TUTTLE_PATH/{data,meta} $TUTTLE_PATH/data/{lib,Plugins,docs} || exit 1
cat $XML/tuttleofx.xml | sed "s/_VERSION_/${TUTTLE_VERSION}/;s/_DATE_/${DATE}/" > $TUTTLE_PATH/meta/package.xml || exit 1
cat $QS/tuttleofx.qs > $TUTTLE_PATH/meta/installscript.qs || exit 1
cp -a $INSTALL_PATH/docs/tuttleofx $TUTTLE_PATH/data/docs/ || exit 1
cat $TUTTLE_PATH/data/docs/tuttleofx/LICENSE.LGPL > $TUTTLE_PATH/meta/license.txt || exit 1
PLUGINS="AnisotropicDiffusion-1.1 BitDepth-1.0 Blur-1.0 Checkerboard-2.0 ColorBars-2.0 ColorCube-2.0 ColorGradation-1.0 ColorSuppress-2.0 ColorTransfer-2.0 ColorWheel-2.0 Component-1.0 Constant-2.0 Crop-1.1 Flip-1.0 FloodFill-1.0 Gamma-1.0 IdKeyer-1.0 Invert-1.0 LensDistort-2.2 LocalMaxima-1.0 MathOperator-1.0 Merge-1.0 NlmDenoiser-1.2 Normalize-1.0 Pinning-1.0 PushPixel-1.2 Ramp-2.0 Resize-1.0 SeExpr-1.0 Sobel-1.0 Text-4.0 Thinning-1.0 TimeShift-1.0"
for i in $PLUGINS; do
  cp -a $INSTALL_PATH/Plugins/${i}.ofx.bundle $TUTTLE_PATH/data/Plugins/ || exit 1
done 
strip -s $TUTTLE_PATH/data/Plugins/*/*/Linux*/*

mkdir -p $TUTTLE_PATH/data/{bin,lib} || exit 1
TUTTLE_DEPENDS=$(ldd $TUTTLE_PATH/data/Plugins/*/*/*/*|grep opt | awk '{print $3}')
for x in $TUTTLE_DEPENDS; do
  cp -v $x $TUTTLE_PATH/data/lib/ || exit 1
done
cp -a $INSTALL_PATH/bin/python $INSTALL_PATH/bin/python2 $INSTALL_PATH/bin/python2.7 $TUTTLE_PATH/data/bin/ || exit 1
rm -f $TUTTLE_PATH/data/lib/libboost_{filesystem,regex,serialization,system,thread}*
strip -s $TUTTLE_PATH/data/lib/*
strip -s $TUTTLE_PATH/data/bin/*
cp -a $INSTALL_PATH/docs/python $INSTALL_PATH/docs/seexpr $TUTTLE_PATH/data/docs/ || exit 1
cat $INSTALL_PATH/docs/python/LICENSE > $TUTTLE_PATH/meta/python-license.txt || exit 1
cat $INSTALL_PATH/docs/seexpr/LICENSE > $TUTTLE_PATH/meta/seexpr-license.txt || exit 1

echo "Done!"

$INSTALL_PATH/bin/repogen -v --update-new-components -p $INSTALLER/packages -c $INSTALLER/config/config.xml $CWD/repo/Linux64 || exit 1

