#!/bin/sh
#
# Build and package Natron for Linux
# Written by Ole-André Rodlie <olear@fxarena.net>
#
#
# (options) sh build.sh (threads, 4 is default)
# 
# Options (optional):
# NOPKG=1 : Don't build installer/repo
# NOCLEAN=1 : Don't remove sdk installation
# REBUILD_SDK=1 : Trigger rebuild of sdk
# NOBUILD=1 : Don't build anything
# SYNC=1 : Sync files with server
# SYNC_DEL=1 : Remove old files from server
# ONLY_NATRON=1 : Don't build plugins
# ONLY_PLUGINS=1 : Don't build natron
# IO=1 : Enable io plug
# MISC=1 : Enable misc plug
# ARENA=1 : Enable arena plug
# OFFLINE_INSTALLER=1: Build offline installer
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

if [ -z "$IO" ]; then
  IO=1
fi
if [ -z "$MISC" ]; then
  MISC=1
fi
if [ -z "$ARENA" ]; then
  ARENA=1
fi
if [ -z "$OFFLINE_INSTALLER" ]; then
  OFFLINE_INSTALLER=0
fi

LOGS=$REPO_DIR/$PKGOS$BIT/logs
FAIL=0

if [ ! -d $LOGS ]; then
  mkdir -p $LOGS || exit 1
fi
if [ "$NOBUILD" != "1" ]; then
  if [ "$ONLY_PLUGINS" != "1" ]; then
    echo -n "Building Natron ... "
    LATEST=1 NOSRC=1 sh $CWD/installer/scripts/build-natron.sh workshop >& $LOGS/natron.$PKGOS$BIT.$TAG.log || FAIL=1
    if [ "$FAIL" != "1" ]; then
      echo OK
    else
      echo ERROR
      sleep 2
      cat $LOGS/natron.$PKGOS$BIT.$TAG.log
    fi
  fi
  if [ "$FAIL" != "1" ] && [ "$ONLY_NATRON" != "1" ]; then
    echo -n "Building Plugins ... "
    LATEST=1 NOSRC=1 BUILD_IO=$IO BUILD_MISC=$MISC BUILD_ARENA=$ARENA sh $CWD/installer/scripts/build-plugins.sh workshop >& $LOGS/plugins.$PKGOS$BIT.$TAG.log || FAIL=1
    if [ "$FAIL" != "1" ]; then
      echo OK
    else
      echo ERROR
      sleep 2
      cat $LOGS/plugins.$PKGOS$BIT.$TAG.log
    fi  
  fi
fi

if [ "$NOPKG" != "1" ] && [ "$FAIL" != "1" ]; then
  echo -n "Building Packages ... "
  OFFLINE=${OFFLINE_INSTALLER} NOTGZ=1 sh $CWD/installer/scripts/build-installer.sh workshop >& $LOGS/installer.$PKGOS$BIT.$TAG.log || FAIL=1
  if [ "$FAIL" != "1" ]; then
    echo OK
  else
    echo ERROR
    sleep 2
    cat $LOGS/installer.$PKGOS$BIT.$TAG.log
  fi 
fi

if [ "$SYNC" == "1" ] && [ "$FAIL" != "1" ]; then
  if [ "$SYNC_DEL" == "1" ]; then
    SYNC_EXTRA="--delete"
  fi
  echo "Syncing packages ... "
  rsync -avz -e ssh --verbose $SYNC_EXTRA $REPO_DIR/$PKGOS$BIT/snapshots/ $REPO_DEST/$PKGOS$BIT/snapshots/ || exit 1
fi

if [ "$FAIL" == "1" ]; then
  exit 1
else
  exit 0
fi
