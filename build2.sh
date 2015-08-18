#!/bin/sh
#
# Build and package Natron for Linux
#
# (options) sh build.sh (threads, 4 is default)
# 
# Options (optional):
# NOPKG=1 : Don't build installer/repo
# NOCLEAN=1 : Don't remove sdk installation
# REBUILD_SDK=1 : Trigger rebuild of sdk
# NOBUILD=1 : Don't build anything
# SYNC=1 : Sync files with server
# ONLY_NATRON=1 : Don't build plugins
# ONLY_PLUGINS=1 : Don't build natron
# IO=1 : Enable io plug
# MISC=1 : Enable misc plug
# ARENA=1 : Enable arena plug
# CV=1 : Enable cv plug
# OFFLINE_INSTALLER=1: Build offline installer in addition to the online installer
# SNAPSHOT=1 : Tag build as snapshot
# TARSRC=1 : tar sources

# USAGE: build2.sh "branch" noThreads

source $(pwd)/common.sh || exit 1

PID=$$
if [ -f $TMP_DIR/natron-build.pid ]; then
  OLDPID=$(cat $TMP_DIR/natron-build.pid)
  PIDS=$(ps aux|awk '{print $2}')
  for i in $PIDS;do
    if [ "$i" == "$OLDPID" ]; then
      echo "already running ..."
      exit 1
    fi
  done
fi
echo $PID > $TMP_DIR/natron-build.pid || exit 1

if [ "$OS" == "GNU/Linux" ]; then
  PKGOS=Linux
else
  echo "Linux-only!"
  exit 1
fi

if [ "$1" == "workshop" ]; then
    BRANCH=$1
    REPO_SUFFIX=snapshot
else
    REPO_SUFFIX=release
fi

if [ "$2" != "" ]; then
    JOBS=$2
else
    #Default to 4 threads
    JOBS=$DEFAULT_MKJOBS
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
if [ -z "$CV" ]; then
  CV=1
fi
if [ -z "$OFFLINE_INSTALLER" ]; then
  OFFLINE_INSTALLER=1
fi

REPO_DIR=$REPO_DIR_PREFIX$REPO_SUFFIX

LOGS=$REPO_DIR/logs
FAIL=0

if [ ! -f $(pwd)/commits-hash.sh ]; then
    touch $CWD/commits-hash.sh
    echo "#!/bin/sh" >> $CWD/commits-hash.sh
    echo "NATRON_DEVEL_GIT=#" >> $CWD/commits-hash.sh
    echo "IOPLUG_DEVEL_GIT=#" >> $CWD/commits-hash.sh
    echo "MISCPLUG_DEVEL_GIT=#" >> $CWD/commits-hash.sh
    echo "ARENAPLUG_DEVEL_GIT=#" >> $CWD/commits-hash.sh
    echo "CVPLUG_DEVEL_GIT=#" >> $CWD/commits-hash.sh
    echo "NATRON_VERSION_NUMBER=#" >> $CWD/commits-hash.sh
fi

if [ ! -d $LOGS ]; then
  mkdir -p $LOGS || exit 1
fi
if [ "$NOBUILD" != "1" ]; then
  if [ "$ONLY_PLUGINS" != "1" ]; then
    echo -n "Building Natron ... "
    MKJOBS=$JOBS MKSRC=${TARSRC} BUILD_SNAPSHOT=${SNAPSHOT} sh $INC_PATH/scripts/build-natron.sh workshop >& $LOGS/natron.$PKGOS$BIT.$TAG.log || FAIL=1
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
    MKJOBS=$JOBS MKSRC=${TARSRC} BUILD_CV=$CV BUILD_IO=$IO BUILD_MISC=$MISC BUILD_ARENA=$ARENA sh $INC_PATH/scripts/build-plugins.sh workshop >& $LOGS/plugins.$PKGOS$BIT.$TAG.log || FAIL=1
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
  OFFLINE=${OFFLINE_INSTALLER} NOTGZ=1 sh $INC_PATH/scripts/build-installer.sh workshop >& $LOGS/installer.$PKGOS$BIT.$TAG.log || FAIL=1
  if [ "$FAIL" != "1" ]; then
    echo OK
  else
    echo ERROR
    sleep 2
    cat $LOGS/installer.$PKGOS$BIT.$TAG.log
  fi 
fi

if [ "$SYNC" == "1" ] && [ "$FAIL" != "1" ]; then
  echo "Syncing packages ... "

  if [ "$BRANCH" == "workshop" ]; then
    LOCAL_REPO_BRANCH=snapshot
    ONLINE_REPO_BRANCH=snapshots
  else
    LOCAL_REPO_BRANCH=release
    ONLINE_REPO_BRANCH=releases
  fi
  LOCAL_REPO_DIR=$REPO_DIR_PREFIX$LOCAL_REPO_BRANCH
  BIT_SUFFIX=bit
  BIT_TAG=$BIT$BIT_SUFFIX

  rsync -avz --progress --delete --verbose -e ssh  $LOCAL_REPO_DIR/packages/ $REPO_DEST/$PKGOS/$ONLINE_REPO_BRANCH/$BIT_TAG/packages

  rsync -avz --progress  --verbose -e ssh $LOCAL_REPO_DIR/installers/ $REPO_DEST/$PKGOS/$ONLINE_REPO_BRANCH/$BIT_TAG/files
fi

if [ "$FAIL" == "1" ]; then
  exit 1
else
  exit 0
fi
