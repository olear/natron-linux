#!/bin/sh
#
# Build Natron Plugins for Linux and FreeBSD.
# Written by Ole-André Rodlie <olear@fxarena.net>
#

source $(pwd)/common.sh || exit 1

if [ "$1" == "workshop" ]; then
  IO_V=$IOPLUG_DEVEL_GIT
  MISC_V=$MISCPLUG_DEVEL_GIT
else
  IO_V=$IOPLUG_STABLE_GIT
  MISC_V=$MISCPLUG_STABLE_GIT
fi

if [ "$IO_V" == "" ]; then
  echo "No git version defined, please check common.sh."
  exit 1
fi

if [ "$MISC_V" == "" ]; then
  echo "No git version defined, please check common.sh."
  exit 1
fi

if [ "$OS" != "GNU/Linux" ]; then
  INSTALL_PATH=/usr/local
else
  if [ ! -d $INSTALL_PATH ]; then
    if [ -f $SRC_PATH/Natron-$SDK_VERSION-Linux-$ARCH-SDK.tar.xz ]; then
      echo "Found binary SDK, extracting ..."
      tar xvJf $SRC_PATH/Natron-$SDK_VERSION-Linux-$ARCH-SDK.tar.xz -C $SDK_PATH/ || exit 1
    else
      echo "Need to build SDK ..."
      sh $CWD/installer/scripts/build-sdk.sh || exit 1
    fi
  fi
fi

if [ -d $TMP_PATH ]; then
  rm -rf $TMP_PATH || exit 1
fi
mkdir -p $TMP_PATH || exit 1

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

if [ -d $INSTALL_PATH/Plugins ]; then
  rm -rf $INSTALL_PATH/Plugins || exit 1
fi
mkdir -p $INSTALL_PATH/Plugins || exit 1
rm -rf $INSTALL_PATH/docs/openfx-* || exit 1

cd $TMP_PATH || exit 1

if [ -f $SRC_PATH/openfx-misc-$MISC_V.tar.gz ]; then
  tar xvf $SRC_PATH/openfx-misc-$MISC_V.tar.gz || exit 1
  cd openfx-misc* || exit 1
else
  git clone $GIT_MISC || exit 1
  cd openfx-misc || exit 1
  git checkout ${MISC_V} || exit 1
  MISC_GIT_VERSION=$(git log|head -1|awk '{print $2}')
  if [ "$MISC_GIT_VERSION" != "$MISC_V" ]; then
    echo "version don't match"
    exit 1
  fi
  git submodule update -i --recursive || exit 1
  if [ "$NOSRC" != "1" ]; then
    (cd .. ; 
      cp -a openfx-misc openfx-misc-$MISC_GIT_VERSION
      (cd openfx-misc-$MISC_GIT_VERSION ; find . -type d -name .git -exec rm -rf {} \;)
      tar cvvzf $CWD/src/openfx-misc-$MISC_GIT_VERSION.tar.gz openfx-misc-$MISC_GIT_VERSION
    )
  fi
fi

if [ "$OS" == "FreeBSD" ]; then
  patch -p0< $CWD/patches/freebsd-openfx-misc-Makefile.diff || exit 1
  gmake DEBUGFLAG=-O3 BITS=$BIT || exit 1
  cp -a Misc/FreeBSD-$BIT-release/Misc.ofx.bundle $INSTALL_PATH/Plugins/ || exit 1
  cp -a CImg/FreeBSD-$BIT-release/CImg.ofx.bundle $INSTALL_PATH/Plugins/ || exit 1
else
  CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" make DEBUGFLAG=-O3 BITS=$BIT || exit 1
  cp -a Misc/Linux-$BIT-release/Misc.ofx.bundle $INSTALL_PATH/Plugins/ || exit 1
  cp -a CImg/Linux-$BIT-release/CImg.ofx.bundle $INSTALL_PATH/Plugins/ || exit 1
fi

mkdir -p $INSTALL_PATH/docs/openfx-misc || exit 1
cp LICENSE README* $INSTALL_PATH/docs/openfx-misc/ || exit 1
echo $MISC_GIT_VERSION > $INSTALL_PATH/docs/openfx-misc/VERSION || exit 1

cd $TMP_PATH || exit 1

if [ -f $CWD/src/openfx-io-$IO_V.tar.gz ]; then
  tar xvf $CWD/src/openfx-io-$IO_V.tar.gz || exit 1
  cd openfx-io* || exit 1
else
  git clone $GIT_IO || exit 1
  cd openfx-io || exit 1
  git checkout ${IO_V} || exit 1
  IO_GIT_VERSION=$(git log|head -1|awk '{print $2}')
  if [ "$IO_GIT_VERSION" != "$IO_V" ]; then
    echo "version don't match"
    exit 1
  fi
  git submodule update -i --recursive || exit 1
  if [ "$NOSRC" != "1" ]; then
    (cd .. ; 
      cp -a openfx-io openfx-io-$IO_GIT_VERSION
      (cd openfx-io-$IO_GIT_VERSION ; find . -type d -name .git -exec rm -rf {} \;)
      tar cvvzf $CWD/src/openfx-io-$IO_GIT_VERSION.tar.gz openfx-io-$IO_GIT_VERSION
    )
  fi
fi

if [ "$OS" == "FreeBSD" ]; then
  patch -p0< $CWD/patches/freebsd-openfx-io-Makefile.diff || exit 1
  if [ "$1" == "workshop" ]; then
    patch -p0< $CWD/patches/freebsd-iofix.diff || exit 1
  fi
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
