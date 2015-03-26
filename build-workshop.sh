#!/bin/sh
#
# Build and package Natron Workshop for Linux
# Written by Ole-André Rodlie <olear@fxarena.net>
#
#
# (options) sh build-workshop.sh (threads, 4 is default)
# 
# Options (optional):
# NOPKG=1 : Don't build any packages.
# NOCLEAN=1 : Don't remove sdk installation (if exist) prior to build, only useful if you just want to rebuild a package or debug.
# REBUILD_SDK=1 : Trigger rebuild of SDK
# NOBUILD=1 : Don't build natron and plugins, only useful in combo with NOCLEAN or NOPKG.
# SYNC=1 : Sync binaries with remote server.
# SYNC_SRC=1 : Sync sources with remote server.
# SYNC_DEL=1 : Remove existing files on remote server.
#

source $(pwd)/common.sh || exit 1

if [ "$OS" == "GNU/Linux" ]; then
  PKGOS=linux
else
  echo "Linux-only!"
  exit 1
fi
if [ "$1" != "" ]; then
  export MKJOBS=$1
fi

if [ "$NOCLEAN" != "1" ]; then
  rm -rf $INSTALL_PATH
fi
if [ "$REBUILD_SDK" == "1" ]; then
  rm -f $SRC_PATH/Natron*SDK.tar.xz
fi

LOGS=$REPO_DIR/branches/workshop/$PKGOS$BIT/logs

if [ ! -d $LOGS ]; then
  mkdir -p $LOGS || exit 1
fi
if [ "$NOBUILD" != "1" ]; then
  echo -n "Building Natron ... "
  LATEST=1 NOSRC=1 sh $CWD/installer/scripts/build-natron.sh workshop >& $LOGS/natron.$PKGOS$BIT.$TAG.log || exit 1
  echo OK
  echo -n "Building Plugins ... "
  LATEST=1 NOSRC=1 sh $CWD/installer/scripts/build-plugins.sh workshop >& $LOGS/plugins.$PKGOS$BIT.$TAG.log || exit 1
  echo OK
fi

if [ "$NOPKG" != "1" ]; then
  echo -n "Building Packages ... "
  NOTGZ=1 sh $CWD/installer/scripts/build-installer.sh workshop >& $LOGS/installer.$PKGOS$BIT.$TAG.log || exit 1
  echo OK
fi

if [ "$SYNC" == "1" ]; then
  if [ "$SYNC_DEL" == "1" ]; then
    SYNC_EXTRA="--delete"
  fi
  echo "Syncing packages ... "
  rsync -avz -e ssh --delete $REPO_DIR/branches/workshop/$PKGOS$BIT/packages/ $REPO_DEST/branches/workshop/$PKGOS$BIT/packages/ || exit 1
  rsync -avz -e ssh $SYNC_EXTRA $REPO_DIR/branches/workshop/$PKGOS$BIT/snapshots/ $REPO_DEST/branches/workshop/$PKGOS$BIT/snapshots/ || exit 1
  rsync -avz -e ssh $SYNC_EXTRA $REPO_DIR/branches/workshop/$PKGOS$BIT/logs/ $REPO_DEST/branches/workshop/$PKGOS$BIT/logs/ || exit 1
fi

if [ "$SYNC_SRC" == "1" ]; then
  echo "Syncing sources ... "
  rsync -avz -e ssh $SRC_PATH/ $REPO_DEST/$REPO_SRC/ || exit 1
fi

exit 0
