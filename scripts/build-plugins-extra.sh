#!/bin/sh
#
# Written by Ole Andre Rodlie <olear@dracolinux.org>
#

gcc -v
sleep 5

GIT_YADIF=https://github.com/devernay/openfx-yadif.git
YADIF_V=4fe05af2d5382a5e10a6e7f65e1103d2f67421f9
GIT_CV=https://github.com/devernay/openfx-opencv.git
CV_V=80dc18f9dcfb16632d3083c7cc63a8ac1dad285d
VERSION=1.0

# Threads
if [ -z "$MKJOBS" ]; then
  MKJOBS=4
fi

# Setup
if [ -z "$ARCH" ]; then
  case "$( uname -m )" in
    i?86) export ARCH=i686 ;;
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
INSTALL_PATH=/opt/Natron-$VERSION
TMP_PATH=$CWD/tmp

if [ -d $TMP_PATH ]; then
  rm -rf $TMP_PATH || exit 1
fi
mkdir -p $TMP_PATH || exit 1

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
YADIF_GIT_VERSION=$(git log|head -1|awk '{print $2}')
if [ "$YADIF_GIT_VERSION" != "$YADIF_V" ]; then
  echo "version don't match"
  exit 1
fi

git submodule update -i --recursive || exit 1

(cd .. ;
  cp -a openfx-yadif openfx-yadif-$YADIF_GIT_VERSION
  (cd openfx-yadif-$YADIF_GIT_VERSION ; find . -type d -name .git -exec rm -rf {} \;)
  tar cvvzf $CWD/src/openfx-yadif-$YADIF_GIT_VERSION.tar.gz openfx-yadif-$YADIF_GIT_VERSION
)

CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" make DEBUGFLAG=-O3 BITS=$BIT || exit 1
cp -a Linux-$BIT-release/*.ofx.bundle $INSTALL_PATH/Plugins/ || exit 1
mkdir -p $INSTALL_PATH/docs/openfx-yadif || exit 1
cp LICENSE README* $INSTALL_PATH/docs/openfx-yadif/
echo $YADIF_GIT_VERSION > $INSTALL_PATH/docs/openfx-yadif/VERSION || exit 1

cd $TMP_PATH || exit 1
git clone $GIT_CV || exit 1
cd openfx-opencv || exit 1
git checkout ${CV_V} || exit 1
CV_GIT_VERSION=$(git log|head -1|awk '{print $2}')
if [ "$CV_GIT_VERSION" != "$CV_V" ]; then
  echo "version don't match"
  exit 1
fi

git submodule update -i --recursive || exit 1

(cd .. ;
  cp -a openfx-opencv openfx-opencv-$CV_GIT_VERSION
  (cd openfx-opencv-$CV_GIT_VERSION ; find . -type d -name .git -exec rm -rf {} \;)
  tar cvvzf $CWD/src/openfx-opencv-$CV_GIT_VERSION.tar.gz openfx-opencv-$CV_GIT_VERSION
)

cd opencv2fx || exit 1
CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" make DEBUGFLAG=-O3 BITS=32 || exit 1
cp -a */Linux-$BIT-release/*.ofx.bundle $INSTALL_PATH/Plugins/ || exit 1
mkdir -p $INSTALL_PATH/docs/openfx-opencv || exit 1
cp LICENSE README* $INSTALL_PATH/docs/openfx-opencv/
echo $CV_GIT_VERSION > $INSTALL_PATH/docs/openfx-opencv/VERSION || exit 1

echo "Done!"

