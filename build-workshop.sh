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
echo "Building Natron ..."
LATEST=1 NOSRC=1 sh $CWD/installer/scripts/build-natron.sh workshop >& $CWD/logs/natron.$PKGOS$BIT.$TAG.log || exit 1
echo "Building Plugins ..."
LATEST=1 NOSRC=1 sh $CWD/installer/scripts/build-plugins.sh workshop >& $CWD/logs/plugins.$PKGOS$BIT.$TAG.log || exit 1

echo "All done ..."
exit 0
