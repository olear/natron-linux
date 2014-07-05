#!/bin/sh
#
# Build Natron for Linux64 (using CentOS 6.2)
# Written by Ole Andre Rodlie <olear@dracolinux.org>
#

gcc -v
sleep 5

# Dist files
GIT_NATRON=https://github.com/MrKepzie/Natron.git
GIT_IO=https://github.com/MrKepzie/openfx-io.git
GIT_MISC=https://github.com/devernay/openfx-misc.git

# Natron version
IO_V=0.9.4
MISC_V=0.9.4
NATRON_V=RB-0.9
SDK_VERSION=0.9
VERSION=0.9.5
RELEASE=8-beta

if [ "$1" == "qt4" ]; then
  RELEASE=${RELEASE}-qt4
else
  RELEASE=${RELEASE}-qt5
fi

# Threads
MKJOBS=4

# Setup
CWD=$(pwd)
INSTALL_PATH=/opt/Natron-$SDK_VERSION
TMP_PATH=$CWD/tmp

if [ ! -d $TMP_PATH ]; then
  mkdir -p $TMP_PATH || exit 1
else
  rm -rf $TMP_PATH || exit 1
  mkdir -p $TMP_PATH || exit 1
fi

# Create release
mkdir -p $CWD/Natron-$VERSION-$RELEASE-linux64/{bin,lib} $CWD/Natron-$VERSION-$RELEASE-linux64/share/{pixmaps,applications} || exit 1
cd $CWD/Natron-$VERSION-$RELEASE-linux64 || exit 1

cp $INSTALL_PATH/bin/Natron* bin/ || exit 1
cp -a $INSTALL_PATH/Plugins . || exit 1
cp -a $INSTALL_PATH/share/OpenColorIO-Configs share/ || exit 1

cp -a $INSTALL_PATH/plugins/{bearer,iconengines,imageformats,graphicssystems} bin/ || exit 1

cp -a $INSTALL_PATH/docs . || exit 1

CORE_DEPENDS=$(ldd bin/*|grep opt | awk '{print $3}')
for i in $CORE_DEPENDS; do
  cp -v $i lib/ || exit 1
done

OFX_DEPENDS=$(ldd Plugins/*/Contents/Linux-x86-64/*|grep opt | awk '{print $3}')
for x in $OFX_DEPENDS; do
  cp -v $x lib/ || exit 1
done

LIB_DEPENDS=$(ldd lib/*|grep opt | awk '{print $3}')
for y in $LIB_DEPENDS; do
  cp -v $y lib/ || exit 1
done

cat $CWD/Natron.sh > Natron || exit 1
cat $CWD/NatronRenderer.sh > NatronRenderer || exit 1
cat $CWD/Install.sh > Install.sh || exit 1
cat $CWD/Uninstall.sh > Uninstall.sh || exit 1
chmod +x Natron NatronRenderer Install.sh Uninstall.sh || exit 1

cp $INSTALL_PATH/share/pixmaps/natronIcon256_linux.png share/pixmaps/ || exit 1
cp $CWD/natron.desktop share/applications/ || exit 1

PLUG_DEPENDS=$(ldd bin/*/*|grep opt | awk '{print $3}')
for z in $PLUG_DEPENDS; do
  cp -v $z lib/ || exit 1
done

tar xvf $CWD/installer/compat.tgz -C lib/ || exit 1
cat $CWD/README.txt > README.txt || exit 1

strip -s bin/*/*
strip -s bin/*
strip -s lib/*
strip -s Plugins/*/Contents/Linux-x86-64/*
chown root:root -R *
find . -type d -name .git -exec rm -rf {} \;

cd .. || exit 1
tar cvvzf Natron-$VERSION-$RELEASE-linux64.tgz Natron-$VERSION-$RELEASE-linux64 || exit 1
