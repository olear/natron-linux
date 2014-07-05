#!/bin/sh
#
# Build OFX Plugins for Linux64 (using CentOS 6.2)
# Written by Ole Andre Rodlie <olear@dracolinux.org>
#

gcc -v
sleep 5

# Dist files
GIT_YADIF=https://github.com/devernay/openfx-yadif.git
YADIF_V=master
GIT_CV=https://github.com/devernay/openfx-opencv.git
CV_V=master

# Natron version
VERSION=0.9

# Threads
MKJOBS=4

# Setup
CWD=$(pwd)
INSTALL_PATH=/opt/Natron-$VERSION
TMP_PATH=$CWD/tmp

if [ ! -d $TMP_PATH ]; then
  mkdir -p $TMP_PATH || exit 1
else
  rm -rf $TMP_PATH || exit 1
  mkdir -p $TMP_PATH || exit 1
fi

# Setup env
export PKG_CONFIG_PATH=$INSTALL_PATH/lib/pkgconfig
export LD_LIBRARY_PATH=$INSTALL_PATH/lib
export PATH=/usr/local/bin:$INSTALL_PATH/bin:$PATH
export QTDIR=$INSTALL_PATH
export BOOST_ROOT=$INSTALL_PATH
export OPENJPEG_HOME=$INSTALL_PATH
export THIRD_PARTY_TOOLS_HOME=$INSTALL_PATH
export PYTHON_HOME=$INSTALL_PATH
export PYTHON_PATH=$INSTALL_PATH/lib/python2.7

mkdir -p $INSTALL_PATH/Plugins || exit 1

cd $TMP_PATH || exit 1
git clone $GIT_YADIF || exit 1
cd openfx-yadif || exit 1
git checkout ${YADIF_V} || exit 1
git submodule update -i --recursive || exit 1
CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" make DEBUGFLAG=-O3 BITS=64 || exit 1
cp -a Linux-64-release/*.ofx.bundle $INSTALL_PATH/Plugins/ || exit 1
mkdir -p $INSTALL_PATH/docs/openfx-yadif || exit 1
cp LICENSE README* $INSTALL_PATH/docs/openfx-yadif/

cd $TMP_PATH || exit 1
git clone $GIT_CV || exit 1
cd openfx-opencv || exit 1
git checkout ${CV_V} || exit 1
git submodule update -i --recursive || exit 1
cd opencv2fx || exit 1
CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" make DEBUGFLAG=-O3 BITS=64 || exit 1
cp -a */Linux-64-release/*.ofx.bundle $INSTALL_PATH/Plugins/ || exit 1
mkdir -p $INSTALL_PATH/docs/openfx-opencv || exit 1
cp LICENSE README* $INSTALL_PATH/docs/openfx-opencv/
