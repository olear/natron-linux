#!/bin/sh
#
# Written by Ole Andre Rodlie <olear@dracolinux.org>
#

gcc -v
sleep 5

VERSION=1.0
MKJOBS=4

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
TUTTLE_V=9daa09f490d03b643e25d0ac125301fb5e07dd1a
#TUTTLE_V=a4912303ed278b5a92decb2d45c2bfac975653b3
git clone https://github.com/tuttleofx/TuttleOFX.git
cd TuttleOFX || exit 1
git checkout $TUTTLE_V || exit 1
TUTTLE_GIT_VERSION=$(git log|head -1|awk '{print $2}')
if [ "$TUTTLE_GIT_VERSION" != "$TUTTLE_V" ]; then
  echo "version don't match"
  exit 1
fi

export TUTTLEOFX=$(pwd)
sed -i 's#http:#https:#g' .gitmodules || exit 1
git submodule update -i --recursive || exit 1

(cd .. ; 
  cp -a TuttleOFX TuttleOFX-$TUTTLE_GIT_VERSION
  (cd TuttleOFX-$TUTTLE_GIT_VERSION ; find . -type d -name .git -exec rm -rf {} \;)
  tar cvvzf $CWD/src/TuttleOFX-$TUTTLE_GIT_VERSION.tar.gz TuttleOFX-$TUTTLE_GIT_VERSION
)

cat $CWD/installer/host.sconf > host.sconf || exit 1

#Ignore errors etc, can't get scons to do a clean build.
CFLAGS="$BF" CXXFLAGS="$BF" scons LINKFLAGS=-v ignore_configure_errors=1 -i -k -j${MKJOBS}

cp -a dist/*/*/production/plugin/*.ofx.bundle $INSTALL_PATH/Plugins/ || exit 1
mkdir $INSTALL_PATH/docs/tuttleofx || exit 1
cp LICENSE.{LGPL,TuttleOFX} AUTH* READ* $INSTALL_PATH/docs/tuttleofx/
echo "Done!"

