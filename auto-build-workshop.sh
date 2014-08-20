#!/bin/sh
#
# Autobuild for Natron
# Written by Ole Andre Rodlie <olear@dracolinux.org>
#

SDK=1.0
CWD=$(pwd)
TMP=$CWD/.autobuild
TAG=$(date +%Y%m%d%H%M)
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

if [ "$OS" == "GNU/Linux" ]; then
  if [ ! -f $CWD/src/Natron-${SDK}-SDK-$PKGOS${BIT}.txz ]; then
    wget http://fxarena.net/natron/source/Natron-${SDK}-SDK-$PKGOS${BIT}.txz -O $CWD/src/Natron-${SDK}-SDK-$PKGOS${BIT}.txz || exit 1
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

if [ ! -f $TMP/NATRON ]; then
  cat $CWD/NATRON_WORKSHOP > $TMP/NATRON || exit 1
fi

if [ ! -f $TMP/IO ]; then
  cat $CWD/IO_WORKSHOP > $TMP/IO || exit 1
fi

if [ ! -f $TMP/MISC ]; then
  cat $CWD/MISC_WORKSHOP > $TMP/MISC || exit 1
fi

while true; do

if [ "$OS" == "GNU/Linux" ]; then
  rm -rf /opt/Natron-$SDK
else
  rm -rf /usr/local/bin/Natron* /usr/local/Plugins /usr/local/share/OpenColor*
fi

cd $TMP/Natron || exit 1
git fetch || exit 1
git merge origin/workshop || exit 1
GITV_NATRON=$(git log|head -1|awk '{print $2}')
ORIG_NATRON=$(cat $TMP/NATRON)
if [ "$GITV_NATRON" != "$ORIG_NATRON" ]; then
  echo "Natron update needed"
  BUILD_NATRON=1
  echo $GITV_NATRON > $CWD/NATRON_WORKSHOP || exit 1
fi

cd $TMP/openfx-io || exit 1
git fetch || exit 1
git merge origin/master || exit 1
GITV_IO=$(git log|head -1|awk '{print $2}')
ORIG_IO=$(cat $TMP/IO)
if [ "$GITV_IO" != "$ORIG_IO" ]; then
  echo "IO update needed"
  BUILD_IO=1
  echo $GITV_IO > $CWD/IO_WORKSHOP || exit 1
fi

cd $TMP/openfx-misc || exit 1
git fetch || exit 1
git merge origin/master || exit 1
GITV_MISC=$(git log|head -1|awk '{print $2}')
ORIG_MISC=$(cat $TMP/MISC)
if [ "$GITV_MISC" != "$ORIG_MISC" ]; then
  echo "Misc update needed"
  BUILD_MISC=1
  echo $GITV_MISC > $CWD/MISC_WORKSHOP || exit 1
fi

if [ "$BUILD_NATRON" == "1" ] || [ "$BUILD_IO" == "1" ] || [ "$BUILD_MISC" == "1" ]; then
  if [ "$BUILD_NATRON" == "1" ]; then
    export MKJOBS=2
    cd $CWD || exit 1
    sh scripts/build-release workshop || exit 1
    echo $GITV_NATRON > $TMP/NATRON || exit 1
  fi
  if [ "$BUILD_IO" == "1" ] || [ "$BUILD_MISC" == "1" ]; then
    cd $CWD || exit 1
    sh scripts/build-plugins.sh workshop || exit 1
    if [ "$BUILD_IO" == "1" ]; then
      echo $GITV_IO > $TMP/IO || exit 1
    fi
    if [ "$BUILD_MISC" == "1" ]; then
      echo $GITV_MISC > $TMP/MISC || exit
    fi
  fi
fi

sleep 300
done

