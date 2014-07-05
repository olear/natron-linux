#!/bin/sh
#
# Build Natron for Linux64 (using CentOS 6.2)
# Written by Ole Andre Rodlie <olear@dracolinux.org>
#

gcc -v
sleep 5

# Dist files
QT4_TAR=qt-everywhere-opensource-src-4.8.6.tar.gz
QIF_TAR=installer-framework-installer-framework-f586369bd5b0a876a148c203b0243a8378b45482.tar.gz

# Threads
MKJOBS=4

# Setup
CWD=$(pwd)
INSTALL_PATH=$CWD/qt
TMP_PATH=$CWD/tmp

if [ -d $INSTALL_PATH ]; then
  rm -rf $INSTALL_PATH
fi
if [ ! -d $TMP_PATH ]; then
  mkdir -p $TMP_PATH || exit 1
else
  rm -rf $TMP_PATH || exit 1
  mkdir -p $TMP_PATH || exit 1
fi

# Setup env
export QTDIR=$INSTALL_PATH

# Install
cd $TMP_PATH || exit 1
QT_TAR=$QT4_TAR
QT_CONF="-no-gif -qt-libpng -no-opengl -no-libmng -no-libtiff -qt-libjpeg -static -no-openssl -confirm-license -release -opensource -nomake demos -nomake docs -nomake examples -no-gtkstyle -no-webkit -I${INSTALL_PATH}/include -L${INSTALL_PATH}/lib"

tar xvf $CWD/../src/$QT_TAR || exit 1
cd qt* || exit 1
CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure -prefix $INSTALL_PATH $QT_CONF || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
cd ..
tar xvf $CWD/../src/$QIF_TAR || exit 1
cd installer* || exit 1
$INSTALL_PATH/bin/qmake || exit 1
make -j${MKJOBS} || exit 1
cp bin/* $CWD/ || exit 1
rm -rf $INSTALL_PATH $TMP_PATH || exit 1
