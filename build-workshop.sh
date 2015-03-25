#!/bin/sh
#
# Build and package Natron Workshop for Linux
# Written by Ole-André Rodlie <olear@fxarena.net>
#

source $(pwd)/common.sh || exit 1

if [ "$OS" == "GNU/Linux" ]; then
  PKGOS=linux
else
  echo "Linux-only!"
  exit 1
fi
if [ ! -d $CWD/logs ]; then
  mkdir -p $CWD/logs || exit 1
fi
if [ "$1" != "" ]; then
  export MKJOBS=$1
fi

rm -rf $INSTALL_PATH

if [ "$CLEAN_BUILD" == "1" ]; then
  rm -f $SRC_PATH/Natron*SDK.tar.xz
fi

echo "Building Natron ..."
LATEST=1 NOSRC=1 sh $CWD/installer/scripts/build-natron.sh workshop >& $CWD/logs/natron.$PKGOS$BIT.$TAG.log || exit 1
echo "Building Plugins ..."
LATEST=1 NOSRC=1 sh $CWD/installer/scripts/build-plugins.sh workshop >& $CWD/logs/plugins.$PKGOS$BIT.$TAG.log || exit 1
echo "Building Packages ..."
NOTGZ=1 sh $CWD/installer/scripts/build-installer.sh workshop >& $CWD/logs/installer.$PKGOS$BIT.$TAG.log || exit 1
echo "All done ..."
exit 0
