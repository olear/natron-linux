#!/bin/sh
#
# Autobuild for Natron
# Written by Ole-André Rodlie <olear@dracolinux.org>
#

source $(pwd)/common.sh || exit 1
CWD=$(pwd)
TMP=$CWD/.autobuild
LOGS=$REPO_DIR/$PKGOS$BIT/logs
if [ ! -d $LOGS ]; then
  mkdir -p $LOGS || exit 1
fi
if [ ! -d $TMP ]; then
  mkdir -p $TMP || exit 1
fi
if [ ! -d $TMP/Natron ]; then
  cd $TMP || exit 1
  git clone $GIT_NATRON || exit 1
  cd Natron || exit 1
  git checkout workshop || exit 1
fi
if [ ! -d $TMP/openfx-io ]; then
  cd $TMP || exit 1
  git clone $GIT_IO || exit 1
fi
if [ ! -d $TMP/openfx-misc ]; then
  cd $TMP || exit 1
  git clone $GIT_MISC || exit 1
fi
if [ ! -d $TMP/openfx-arena ]; then
  cd $TMP || exit 1
  git clone $GIT_ARENA || exit 1
fi

while :
do

source $CWD/common.sh
FAIL=0
echo "Running ..."

BUILD_NATRON=0
cd $TMP/Natron 
git fetch --all || FAIL=1
git merge origin/workshop || FAIL=1
GITV_NATRON=$(git log|head -1|awk '{print $2}')
ORIG_NATRON=$NATRON_DEVEL_GIT
echo "Natron $GITV_NATRON vs. $ORIG_NATRON"
if [ "$GITV_NATRON" != "$ORIG_NATRON" ] && [ "$FAIL" != "1" ]; then
  echo "Natron update needed"
  BUILD_NATRON=1
fi
BUILD_IO=0
if [ "$FAIL" != "1" ]; then
  cd $TMP/openfx-io
  git fetch --all || FAIL=1
  git merge origin/master || FAIL=1
  GITV_IO=$(git log|head -1|awk '{print $2}')
  ORIG_IO=$IOPLUG_DEVEL_GIT
  echo "IO $GITV_IO vs. $ORIG_IO"
  if [ "$GITV_IO" != "$ORIG_IO" ] && [ "$FAIL" != "1" ]; then
    echo "IO update needed"
    BUILD_IO=1
  fi
fi
BUILD_MISC=0
if [ "$FAIL" != "1" ]; then
  cd $TMP/openfx-misc
  git fetch --all || FAIL=1
  git merge origin/master || FAIL=1
  GITV_MISC=$(git log|head -1|awk '{print $2}')
  ORIG_MISC=$MISCPLUG_DEVEL_GIT
  echo "Misc $GITV_MISC vs. $ORIG_MISC"
  if [ "$GITV_MISC" != "$ORIG_MISC" ] && [ "$FAIL" != "1" ]; then
    echo "Misc update needed"
    BUILD_MISC=1
  fi
fi
BUILD_ARENA=0
if [ "$FAIL" != "1" ]; then
  cd $TMP/openfx-arena
  git fetch --all || FAIL=1
  git merge origin/master || FAIL=1
  GITV_ARENA=$(git log|head -1|awk '{print $2}')
  ORIG_ARENA=$ARENAPLUG_DEVEL_GIT
  echo "Arena $GITV_ARENA vs. $ORIG_ARENA"
  if [ "$GITV_ARENA" != "$ORIG_ARENA" ] && [ "$FAIL" != "1" ]; then
    echo "Arena update needed"
    BUILD_ARENA=1
  fi
fi

cd $CWD || exit 1
if [ "$FAIL" != "1" ]; then
  if [ "$BUILD_NATRON" == "1" ] || [ "$BUILD_IO" == "1" ] || [ "$BUILD_MISC" == "1" ] || [ "$BUILD_ARENA" == "1" ]; then
    echo "Start your engines ..."
    if [ "$BUILD_NATRON" == "1" ]; then
      echo "Building Natron ..."
      NOPKG=1 ONLY_NATRON=1 sh build-snapshots.sh || FAIL=1
    fi
    if [ "$BUILD_IO" == "1" ] && [ "$FAIL" != "1" ]; then
      echo "Building IO ..."
      NOPKG=1 ONLY_PLUGINS=1 IO=1 MISC=0 ARENA=0 sh build-snapshots.sh || FAIL=1
    fi
    if [ "$BUILD_MISC" == "1" ] && [ "$FAIL" != "1" ]; then
      echo "Building Misc ..."
      NOPKG=1 ONLY_PLUGINS=1 IO=0 MISC=1 ARENA=0 sh build-snapshots.sh || FAIL=1
    fi
    if [ "$BUILD_ARENA" == "1" ] && [ "$FAIL" != "1" ]; then
      echo "Building Arena ..."
      NOPKG=1 ONLY_PLUGINS=1 IO=0 MISC=0 ARENA=1 sh build-snapshots.sh || FAIL=1
    fi
    if [ "$FAIL" != "1" ]; then
      echo "Building repo/installer ..."
      NOBUILD=1 sh build-snapshots.sh || FAIL=1
    fi
    #if [ "$FAIL" != "1" ]; then
    #  echo "Syncing binaries ..."
    #  NOBUILD=1 NOPKG=1 SYNC=1 sh build-snapshots.sh || FAIL=1
    #fi
  fi
fi

echo "Idle ..."
sleep 600
done

