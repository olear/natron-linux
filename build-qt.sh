#!/bin/sh
#
# Build Natron for Linux64 (using CentOS 6.2)
# Written by Ole Andre Rodlie <olear@dracolinux.org>
#

gcc -v
sleep 5

# Dist files
QT4_TAR=qt-everywhere-opensource-src-4.8.6.tar.gz
QT_TAR=qt-everywhere-opensource-src-5.3.0.tar.gz

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

# Install
cd $TMP_PATH || exit 1
QT_CONF="-no-openssl -opengl desktop -opensource -nomake examples -nomake tests -release -no-gtkstyle -confirm-license -no-c++11 -I${INSTALL_PATH}/include -L${INSTALL_PATH}/lib"

if [ "$1" == "qt4" ];then
  QT_TAR=$QT4_TAR
  QT_CONF="-no-openssl -confirm-license -release -opensource -opengl desktop -nomake demos -nomake docs -nomake examples -no-gtkstyle -no-webkit -I${INSTALL_PATH}/include -L${INSTALL_PATH}/lib"
fi

tar xvf $CWD/src/$QT_TAR || exit 1
cd qt* || exit 1
if [ "$1" != "qt4" ]; then
  patch -p0< $CWD/no-egl.diff || exit 1
fi
CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure -prefix $INSTALL_PATH $QT_CONF || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/qt || exit 1
cp README LICENSE.LGPL LGPL_EXCEPTION.txt $INSTALL_PATH/docs/qt/ || exit 1

echo "qt done"
