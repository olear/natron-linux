#!/bin/sh
#
# Autobuild for Natron
# Written by Ole Andre Rodlie <olear@dracolinux.org>
#

SDK=1.0
CWD=$(pwd)
TMP=$CWD/.autobuild
GIT_NATRON=https://github.com/MrKepzie/Natron.git
GIT_IO=https://github.com/MrKepzie/openfx-io.git
GIT_MISC=https://github.com/devernay/openfx-misc.git
OS=$(uname -o)
if [ -z "$ARCH" ]; then
  case "$( uname -m )" in
    i?86) export BIT=32 ;;
    amd64) export BIT=64 ;;
       x86_64) export BIT=64 ;;
  esac
fi
if [ "$OS" == "GNU/Linux" ]; then
  PKGOS=linux
else
  PKGOS=freebsd
fi

if [ ! -d $TMP ]; then
  mkdir -p $TMP || exit 1
fi

if [ ! -d $CWD/src ]; then
  mkdir -p $CWD/src || exit 1
fi

if [ ! -d $CWD/logs ]; then
  mkdir -p $CWD/logs || exit 1
fi
if [ "$OS" == "GNU/Linux" ]; then
  if [ ! -f $CWD/src/Natron-${SDK}-SDK-$PKGOS${BIT}.txz ]; then
    wget http://snapshots.natronvfx.com/source/Natron-${SDK}-SDK-$PKGOS${BIT}.txz -O $CWD/src/Natron-${SDK}-SDK-$PKGOS${BIT}.txz || exit 1
  fi
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

while :
do

FAIL=0
echo "Running ..."
TAG=$(date +%Y%m%d%H%M)

if [ "$OS" == "GNU/Linux" ]; then
  rm -rf /opt/Natron-$SDK
else
  rm -rf /usr/local/bin/Natron* /usr/local/Plugins /usr/local/share/OpenColor*
fi

BUILD_NATRON=0
cd $TMP/Natron 
git fetch || FAIL=1
git merge origin/workshop || FAIL=1
GITV_NATRON=$(git log|head -1|awk '{print $2}')
ORIG_NATRON=$(cat $CWD/NATRON_WORKSHOP)
echo "Natron $GITV_NATRON vs. $ORIG_NATRON"
if [ "$GITV_NATRON" != "$ORIG_NATRON" ] && [ "$FAIL" != "1" ]; then
  echo "Natron update needed"
  BUILD_NATRON=1
  echo $GITV_NATRON > $CWD/NATRON_WORKSHOP || FAIL=1
fi

echo $FAIL

BUILD_IO=0
if [ "$FAIL" != "1" ]; then
cd $TMP/openfx-io
git fetch || FAIL=1
git merge origin/master || FAIL=1
GITV_IO=$(git log|head -1|awk '{print $2}')
ORIG_IO=$(cat $CWD/IO_WORKSHOP)
echo "IO $GITV_IO vs. $ORIG_IO"
if [ "$GITV_IO" != "$ORIG_IO" ] && [ "$FAIL" != "1" ]; then
  echo "IO update needed"
  BUILD_IO=1
  echo $GITV_IO > $CWD/IO_WORKSHOP || FAIL=1
fi
fi

echo $FAIL

BUILD_MISC=0
if [ "$FAIL" != "1" ]; then
cd $TMP/openfx-misc
git fetch || FAIL=1
git merge origin/master || FAIL=1
GITV_MISC=$(git log|head -1|awk '{print $2}')
ORIG_MISC=$(cat $CWD/MISC_WORKSHOP)
echo "Misc $GITV_MISC vs. $ORIG_MISC"
if [ "$GITV_MISC" != "$ORIG_MISC" ] && [ "$FAIL" != "1" ]; then
  echo "Misc update needed"
  BUILD_MISC=1
  echo $GITV_MISC > $CWD/MISC_WORKSHOP || FAIL=1
fi
fi

echo $FAIL

if [ "$FAIL" != "1" ]; then
if [ "$BUILD_NATRON" == "1" ] || [ "$BUILD_IO" == "1" ] || [ "$BUILD_MISC" == "1" ]; then
  if [ "$OS" == "GNU/Linux" ]; then
    tar xvfJ $CWD/src/Natron-${SDK}-SDK-$PKGOS${BIT}.txz -C /opt/ || FAIL=1
  fi

  echo $FAIL

  if [ "$FAIL" != "1" ]; then
  cd $CWD
  echo "Building Natron ..."
  sh scripts/build-release.sh workshop >& $CWD/logs/natron.$PKGOS$BIT.$TAG.log || FAIL=1
  if [ "$BUILD_NATRON" == "1" ] && [ "$FAIL" != "1" ]; then
    echo $TAG > $CWD/NATRON_WORKSHOP_PKG || FAIL=1
  fi
  fi
  
  echo $FAIL

  if [ "$FAIL" != "1" ];then
  cd $CWD
  echo "Building plugins ..."
  sh scripts/build-plugins.sh workshop >& $CWD/logs/plugins.$PKGOS$BIT.$TAG.log || FAIL=1
  if [ "$BUILD_IO" == "1" ] && [ "$FAIL" != "1" ]; then
    echo $TAG > $CWD/IO_WORKSHOP_PKG || FAIL=1
  fi
  if [ "$BUILD_MISC" == "1" ] && [ "$FAIL" != "1" ]; then
    echo $TAG > $CWD/MISC_WORKSHOP_PKG || FAIL=1
  fi
  fi
  
  echo $FAIL

  if [ "$FAIL" != "1" ]; then
  cd $CWD
  rm -rf $CWD/repo
  echo "Building repository ..."
  sh scripts/build-package.sh workshop >& $CWD/logs/setup.$PKGOS$BIT.$TAG.log || FAIL=1
  #if [ -d repo/$PKGOS$BIT/workshop ] && [ "$FAIL" != "1" ]; then
  #  rsync -avz -e ssh --delete repo/$PKGOS$BIT/workshop/repo/ olear@10.0.0.135:/srv/www/snapshots.natronvfx.com/$PKGOS$BIT/
  #fi
  fi

fi
fi

#if [ -d $CWD/logs ]; then
#  rsync -avz -e ssh $CWD/logs/ olear@10.0.0.135:/srv/www/snapshots.natronvfx.com/logs/ 
#fi
#if [ -d $CWD/src ]; then
#  rsync -avz -e ssh $CWD/src/ olear@10.0.0.135:/srv/www/snapshots.natronvfx.com/source/
#fi

echo "All done..."
sleep 600
done

