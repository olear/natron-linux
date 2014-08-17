#!/bin/sh
#
# Build Natron Core Plug-ins for Linux and FreeBSD.
# Written by Ole Andre Rodlie <olear@dracolinux.org>
#

gcc -v
sleep 5

GIT_IO=https://github.com/MrKepzie/openfx-io.git
GIT_MISC=https://github.com/devernay/openfx-misc.git
IO_V=$(cat IO_RELEASE)
MISC_V=$(cat MISC_RELEASE)
SDK_VERSION=1.0

# Threads
if [ -z "$MKJOBS" ]; then
  MKJOBS=4
fi

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
OS=$(uname -o)
CWD=$(pwd)

if [ "$OS" == "GNU/Linux" ]; then
  INSTALL_PATH=/opt/Natron-$SDK_VERSION
else
  INSTALL_PATH=/usr/local
fi

TMP_PATH=$CWD/tmp

if [ -d $TMP_PATH ]; then
  rm -rf $TMP_PATH || exit 1
fi
mkdir -p $TMP_PATH || exit 1
mkdir -p $CWD/src

# Setup env
export PKG_CONFIG_PATH=$INSTALL_PATH/lib/pkgconfig:$INSTALL_PATH/libdata/pkgconfig
export LD_LIBRARY_PATH=$INSTALL_PATH/lib
export PATH=/usr/local/bin:$INSTALL_PATH/bin:$PATH
export QTDIR=$INSTALL_PATH
export BOOST_ROOT=$INSTALL_PATH
export OPENJPEG_HOME=$INSTALL_PATH
export THIRD_PARTY_TOOLS_HOME=$INSTALL_PATH

if [ "$OS" == "FreeBSD" ]; then
  export CC=clang
  export CXX=clang++
fi

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

(cd .. ; 
  cp -a openfx-misc openfx-misc-$MISC_GIT_VERSION
  (cd openfx-misc-$MISC_GIT_VERSION ; find . -type d -name .git -exec rm -rf {} \;)
  tar cvvzf $CWD/src/openfx-misc-$MISC_GIT_VERSION.tar.gz openfx-misc-$MISC_GIT_VERSION
)

if [ "$OS" == "FreeBSD" ]; then
  # gmake dont honor flags, avoid waisting time just patch ...
  patch -p0< $CWD/patches/freebsd-openfx-misc-Makefile.diff || exit 1
  gmake DEBUGFLAG=-O3 BITS=$BIT || exit 1
  cp -a Misc/FreeBSD-$BIT-release/Misc.ofx.bundle $INSTALL_PATH/Plugins/ || exit 1
else
  CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" make DEBUGFLAG=-O3 BITS=$BIT || exit 1
  cp -a Misc/Linux-$BIT-release/Misc.ofx.bundle $INSTALL_PATH/Plugins/ || exit 1
fi

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

(cd .. ; 
  cp -a openfx-io openfx-io-$IO_GIT_VERSION
  (cd openfx-io-$IO_GIT_VERSION ; find . -type d -name .git -exec rm -rf {} \;)
  tar cvvzf $CWD/src/openfx-io-$IO_GIT_VERSION.tar.gz openfx-io-$IO_GIT_VERSION
)

if [ "$OS" == "FreeBSD" ]; then
  gmake DEBUGFLAG=-O3 BITS=$BIT || exit 1
  cp -a IO/FreeBSD-$BIT-release/IO.ofx.bundle $INSTALL_PATH/Plugins/ || exit 1
else
  CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" make DEBUGFLAG=-O3 BITS=$BIT || exit 1
  cp -a IO/Linux-$BIT-release/IO.ofx.bundle $INSTALL_PATH/Plugins/ || exit 1
fi

mkdir -p $INSTALL_PATH/docs/openfx-io || exit 1
cp LICENSE README* $INSTALL_PATH/docs/openfx-io/ || exit 1
echo $IO_GIT_VERSION > $INSTALL_PATH/docs/openfx-io/VERSION || exit 1

echo "Done!"