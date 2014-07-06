#!/bin/sh
#
# Build Natron for Linux64 (using CentOS 6.2)
# Written by Ole Andre Rodlie <olear@dracolinux.org>
#

gcc -v
sleep 5

# Dist files
GIT_NATRON=https://github.com/MrKepzie/Natron.git

# Natron version
NATRON_REL_V=RB-0.9
NATRON_WS_V=workshop
SDK_VERSION=0.9

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

# Setup env
export PKG_CONFIG_PATH=$INSTALL_PATH/lib/pkgconfig
export LD_LIBRARY_PATH=$INSTALL_PATH/lib
export PATH=/usr/local/bin:$INSTALL_PATH/bin:$PATH
export QTDIR=$INSTALL_PATH
export BOOST_ROOT=$INSTALL_PATH
export OPENJPEG_HOME=$INSTALL_PATH
export THIRD_PARTY_TOOLS_HOME=$INSTALL_PATH

# Install natron
cd $TMP_PATH || exit 1

git clone $GIT_NATRON || exit 1
cd Natron || exit 1

git checkout ${NATRON_V} || exit 1
REL_GIT_VERSION=$(git log|head -1|awk '{print $2}')
if [ "$REL_GIT_VERSION" != "" ]; then
  echo $REL_GIT_VERSION > $INSTALL_PATH/NATRON_RELEASE_TAG || exit 1
fi

git submodule update -i --recursive || exit 1

cat $CWD/config.pri > config.pri || exit 1
patch -p0< $CWD/patches/stylefix.diff || exit 1

mkdir build || exit 1
cd build || exit 1

$INSTALL_PATH/bin/qmake -r CONFIG+=release DEFINES+=QT_NO_DEBUG_OUTPUT ../Project.pro || exit 1
make -j${MKJOBS} || exit 1

cp App/Natron $INSTALL_PATH/bin/ || exit 1
cp Renderer/NatronRenderer $INSTALL_PATH/bin/ || exit 1

rm -rf * || exit 1

$INSTALL_PATH/bin/qmake -r CONFIG+=debug ../Project.pro || exit 1
make -j${MKJOBS} || exit 1

cp App/Natron $INSTALL_PATH/bin/Natron.debug || exit 1
cp Renderer/NatronRenderer $INSTALL_PATH/bin/NatronRenderer.debug || exit 1

cd .. || exit 1
rm -rf build

git checkout workshop || exit 1
WS_GIT_VERSION=$(git log|head -1|awk '{print $2}')
if [ "$WS_GIT_VERSION" != "" ]; then
  echo $WS_GIT_VERSION > $INSTALL_PATH/NATRON_WORKSHOP_TAG || exit 1
fi

git submodule update -i --recursive || exit 1

cat $CWD/config.pri > config.pri || exit 1

mkdir build || exit 1
cd build || exit 1

$INSTALL_PATH/bin/qmake -r CONFIG+=release DEFINES+=QT_NO_DEBUG_OUTPUT ../Project.pro || exit 1
make -j${MKJOBS} || exit 1

cp App/Natron $INSTALL_PATH/bin/NatronWS || exit 1
cp Renderer/NatronRenderer $INSTALL_PATH/bin/NatronRendererWS || exit 1

rm -rf * || exit 1

$INSTALL_PATH/bin/qmake -r CONFIG+=debug ../Project.pro || exit 1
make -j${MKJOBS} || exit 1

cp App/Natron $INSTALL_PATH/bin/NatronWS.debug || exit 1
cp Renderer/NatronRenderer $INSTALL_PATH/bin/NatronRendererWS.debug || exit 1

cp -a ../Gui/Resources/OpenColorIO-Configs $INSTALL_PATH/share/ || exit 1
mkdir -p $INSTALL_PATH/docs/natron || exit 1
cp ../LICENSE.txt ../README* ../BUGS* ../CONTRI* ../Documentation/* $INSTALL_PATH/docs/natron/ || exit 1
mkdir -p $INSTALL_PATH/share/pixmaps || exit 1
cp ../Gui/Resources/Images/natronIcon256_linux.png $INSTALL_PATH/share/pixmaps/ || exit 1
