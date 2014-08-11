#!/bin/sh
#
# Written by Ole Andre Rodlie <olear@dracolinux.org>
#

GIT_IO=https://github.com/MrKepzie/openfx-io.git
GIT_MISC=https://github.com/devernay/openfx-misc.git

IO_V=60c1cccf6fc81908df25142654627588d168b8d0
MISC_V=befda3ee794cc97ff2fa51f5d84b2b8c5efef5f7
SDK_VERSION=1.0

# Setup
if [ -z "$ARCH" ]; then
  case "$( uname -m )" in
    i?86) export ARCH=i686 ;;
    amd64) export ARCH=x86_64 ;;
       *) export ARCH=$( uname -m ) ;;
  esac
fi
if [ "$ARCH" = "i686" ]; then
  BF="-O2 -march=i686 -mtune=i686"
  BIT=32
elif [ "$ARCH" = "x86_64" ]; then
  BF="-O2 -fPIC"
  BIT=64
else
  BF="-O2"
fi
CWD=$(pwd)
INSTALL_PATH=/usr/local
TMP_PATH=$CWD/tmp

if [ -d $TMP_PATH ]; then
  rm -rf $TMP_PATH || exit 1
fi
  mkdir -p $TMP_PATH || exit 1

# Setup env
export PKG_CONFIG_PATH=$INSTALL_PATH/libdata/pkgconfig:$INSTALL_PATH/lib/pkgconfg
export LD_LIBRARY_PATH=$INSTALL_PATH/lib
export PATH=/usr/local/bin:$INSTALL_PATH/bin:$PATH
export BOOST_ROOT=$INSTALL_PATH
export CC=clang
export CXX=clang++

mkdir -p $INSTALL_PATH/Plugins || exit 1

cd $TMP_PATH || exit 1

git clone $GIT_MISC || exit 1
cd openfx-misc || exit 1
git checkout ${MISC_V} || exit 1
MISC_GIT_VERSION=$(git log|head -1|awk '{print $2}')
if [ "$MISC_GIT_VERSION" != "$MISC_V" ]; then
  echo "version don't match"
  exit 1
fi
git submodule update -i --recursive || exit 1

# gmake dont honor flags, avoid waisting time just patch ...
patch -p0< $CWD/patches/freebsd-openfx-misc-Makefile.diff || exit 1

# OpenFX dont support FreeBSD
patch -p0< $CWD/patches/freebsd-openfx-Plugins-Makefile.diff || exit 1

gmake DEBUGFLAG=-O3 BITS=$BIT || exit 1
cp -a Misc/FreeBSD-$BIT-release/Misc.ofx.bundle $INSTALL_PATH/Plugins/ || exit 1
mkdir -p $INSTALL_PATH/docs/openfx-misc || exit 1
cp LICENSE README* $INSTALL_PATH/docs/openfx-misc/ || exit 1
echo $MISC_GIT_VERSION > $INSTALL_PATH/docs/openfx-misc/VERSION || exit 1

cd $TMP_PATH || exit 1

git clone $GIT_IO || exit 1
cd openfx-io || exit 1
git checkout ${IO_V} || exit 1
IO_GIT_VERSION=$(git log|head -1|awk '{print $2}')
if [ "$IO_GIT_VERSION" != "$IO_V" ]; then
  echo "version don't match"
  exit 1
fi
git submodule update -i --recursive || exit 1

# OpenFX dont support FreeBSD
patch -p0< $CWD/patches/freebsd-openfx-Plugins-Makefile.diff || exit 1

gmake DEBUGFLAG=-O3 BITS=$BIT || exit 1
cp -a IO/FreeBSD-$BIT-release/IO.ofx.bundle $INSTALL_PATH/Plugins/ || exit 1
mkdir -p $INSTALL_PATH/docs/openfx-io || exit 1
cp LICENSE README* $INSTALL_PATH/docs/openfx-io/ || exit 1
echo $IO_GIT_VERSION > $INSTALL_PATH/docs/openfx-io/VERSION || exit 1

echo "Done!"
