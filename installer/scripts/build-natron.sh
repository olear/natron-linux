#!/bin/sh
#
# Build Natron for Linux and FreeBSD.
# Written by Ole-André Rodlie <olear@fxarena.net>
#

gcc -v
sleep 5

GIT_NATRON=https://github.com/MrKepzie/Natron.git

if [ "$1" == "workshop" ];then
NATRON_REL_V=$(cat tags/NATRON_WORKSHOP)
else
NATRON_REL_V=$(cat tags/NATRON_RELEASE)
fi

if [ "$CUSTOM" != "" ]; then
  NATRON_REL_V=$CUSTOM
fi

NATRON_REL_B=workshop

if [ -z "$SDK_VERSION" ]; then
  SDK_VERSION=2.0
fi

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
elif [ "$ARCH" = "x86_64" ]; then
  BF="-O2 -fPIC"
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
export PYTHON_HOME=$INSTALL_PATH
export PYTHON_PATH=$INSTALL_PATH/lib/python3.4
export PYTHON_INCLUDE=$INSTALL_PATH/include/python3.4

# Install natron
cd $TMP_PATH || exit 1

if [ -f $CWD/src/Natron-$NATRON_REL_V.tar.gz ]; then
tar xvf $CWD/src/Natron-$NATRON_REL_V.tar.gz || exit 1
cd Natron* || exit 1
else
git clone $GIT_NATRON || exit 1
cd Natron || exit 1

git checkout ${NATRON_REL_V} || exit 1
#git checkout workshop || exit 1
REL_GIT_VERSION=$(git log|head -1|awk '{print $2}')
if [ "$NATRON_REL_V" != "$REL_GIT_VERSION" ]; then
  echo "version mismatch: $NATRON_REL_V vs. $REL_GIT_VERSION"
  exit 1
fi

git submodule update -i --recursive || exit 1

(cd .. ;
  cp -a Natron Natron-$REL_GIT_VERSION
  (cd Natron-$REL_GIT_VERSION ; find . -type d -name .git -exec rm -rf {} \;)
  tar cvvzf $CWD/src/Natron-$REL_GIT_VERSION.tar.gz Natron-$REL_GIT_VERSION
)
fi

cat $CWD/installer/GitVersion.h | sed "s#__BRANCH__#${NATRON_REL_B}#;s#__COMMIT__#${REL_GIT_VERSION}#" > Global/GitVersion.h || exit 1

if [ "$OS" == "GNU/Linux" ]; then
  cat $CWD/installer/config.pri > config.pri || exit 1
else
  cat $CWD/installer/config-freebsd.pri > config.pri || exit 1
fi

# fix for Linux
if [ "$OS" == "GNU/Linux" ]; then
  patch -p0< $CWD/patches/stylefix.diff || exit 1
  #if [ "$1" == "workshop" ];then
  #  patch -p0< $CWD/patches/gcc47fix.diff || exit 1
  #fi
else
if [ "$1" == "workshop" ]; then
patch -p0< $CWD/patches/freebsd-buildfix.diff || exit 1
fi
fi

rm -rf build
mkdir build || exit 1
cd build || exit 1

if [ "$OS" == "FreeBSD" ]; then
CXX=clang++ CC=clang CFLAGS="$BF" CXXFLAGS="-std=c++11 $BF" $INSTALL_PATH/bin/qmake-qt4 -r CONFIG+=release DEFINES+=QT_NO_DEBUG_OUTPUT ../Project.pro || exit 1
else
CFLAGS="$BF" CXXFLAGS="$BF" $INSTALL_PATH/bin/qmake -r CONFIG+=release DEFINES+=QT_NO_DEBUG_OUTPUT ../Project.pro || exit 1
fi

make -j${MKJOBS} || exit 1

cp App/Natron $INSTALL_PATH/bin/ || exit 1
cp Renderer/NatronRenderer $INSTALL_PATH/bin/ || exit 1

rm -rf * || exit 1

if [ "$NODEBUG" == "" ]; then
if [ "$OS" == "FreeBSD" ]; then
CXX=clang++ CC=clang CFLAGS="$BF" CXXFLAGS="-std=c++11 $BF" $INSTALL_PATH/bin/qmake-qt4 -r CONFIG+=debug ../Project.pro || exit 1
else
CFLAGS="$BF" CXXFLAGS="$BF" $INSTALL_PATH/bin/qmake -r CONFIG+=debug ../Project.pro || exit 1
fi

make -j${MKJOBS} || exit 1
cp App/Natron $INSTALL_PATH/bin/Natron.debug || exit 1
cp Renderer/NatronRenderer $INSTALL_PATH/bin/NatronRenderer.debug || exit 1
fi

cp -a ../Gui/Resources/OpenColorIO-Configs $INSTALL_PATH/share/ || exit 1
mkdir -p $INSTALL_PATH/docs/natron || exit 1
cp ../LICENSE.txt ../README* ../BUGS* ../CONTRI* ../Documentation/* $INSTALL_PATH/docs/natron/
mkdir -p $INSTALL_PATH/share/pixmaps || exit 1
cp ../Gui/Resources/Images/natronIcon256_linux.png $INSTALL_PATH/share/pixmaps/ || exit 1
echo $NATRON_REL_V > $INSTALL_PATH/docs/natron/VERSION || exit 1

echo "Done!"

