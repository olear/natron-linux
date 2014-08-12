#!/bin/sh
#
# Written by Ole Andre Rodlie <olear@dracolinux.org>
#

# Dist files
SRC_URL=http://fxarena.net/natron/source
QIFW_TAR=installer-framework-installer-framework-f586369bd5b0a876a148c203b0243a8378b45482.tar.gz
CAIRO_TAR=cairo-1.12.16.tar.xz

# SDK version
VERSION=1.0

# Arch
if [ -z "$ARCH" ]; then
  case "$( uname -m )" in
    i?86) export ARCH=i686 ;;
    amd64) export ARCH=x86_64 ;;
       *) export ARCH=$( uname -m ) ;;
  esac
fi
if [ "$ARCH" = "i686" ]; then
  BF="-O2 -march=i686 -mtune=i686"
elif [ "$ARCH" = "x86_64" ]; then
  BF="-O2 -fPIC"
else
  BF="-O2"
fi
SDK=FreeBSD-$ARCH-SDK

# Threads
if [ -z "$MKJOBS" ]; then
  MKJOBS=4
fi

# Setup
CWD=$(pwd)
INSTALL_PATH=/usr/local
TMP_PATH=$CWD/tmp

if [ -d $TMP_PATH ]; then
  rm -rf $TMP_PATH || exit 1
fi
mkdir -p $TMP_PATH || exit 1

if [ ! -d $CWD/src ]; then
  mkdir -p $CWD/src || exit 1
fi

# Setup env
export PKG_CONFIG_PATH=$INSTALL_PATH/lib/pkgconfig:/usr/local/libdata/pkgconfig
export LD_LIBRARY_PATH=$INSTALL_PATH/lib
export PATH=/usr/local/bin:$INSTALL_PATH/bin:$PATH
export QTDIR=$INSTALL_PATH
export BOOST_ROOT=$INSTALL_PATH

# Install cairo
cd $TMP_PATH || exit 1
if [ ! -f $CWD/src/$CAIRO_TAR ]; then
  wget $SRC_URL/$CAIRO_TAR -O $CWD/src/$CAIRO_TAR || exit 1
fi
tar xvf $CWD/src/$CAIRO_TAR || exit 1
cd cairo* || exit 1
CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/cairo || exit 1
cp COPYING* README AUTHORS $INSTALL_PATH/docs/cairo/ || exit 1

# QTIFW
# Broken, fix
#cd $TMP_PATH || exit 1
#if [ ! -f $CWD/src/$QIFW_TAR ]; then
#  wget $SRC_URL/$QIFW_TAR -O $CWD/src/$QIFW_TAR || exit 1
#fi
#tar xvf $CWD/src/$QIFW_TAR || exit 1
#cd installer* || exit 1
#qmake-qt4 CONFIG+=staticlib || exit 1
#make -j${MKJOBS} || exit 1
#strip -s bin/*
#cp bin/* $INSTALL_PATH/bin/ || exit 1

echo "Natron SDK Done!"
