#!/bin/sh
#
# Build Natron Plugins for Linux and FreeBSD.
# Written by Ole-André Rodlie <olear@fxarena.net>
#

source $(pwd)/common.sh || exit 1

if [ "$1" == "workshop" ]; then
  IO_V=$IOPLUG_DEVEL_GIT
  MISC_V=$MISCPLUG_DEVEL_GIT
  ARENA_V=$ARENAPLUG_DEVEL_GIT
  CV_V=$CVPLUG_DEVEL_GIT
else
  IO_V=$IOPLUG_STABLE_GIT
  MISC_V=$MISCPLUG_STABLE_GIT
  ARENA_V=$ARENAPLUG_STABLE_GIT
  CV_V=$CVPLUG_STABLE_GIT
fi

if [ "$MISC_V" == "" ] || [ "$IO_V" == "" ] || [ "$ARENA_V" == "" ] || [ "$CV_V" == "" ]; then
  echo "No git version defined, please check common.sh."
  exit 1
fi

if [ ! -d $INSTALL_PATH ]; then
  if [ -f $SRC_PATH/Natron-$SDK_VERSION-Linux-$ARCH-SDK.tar.xz ]; then
    echo "Found binary SDK, extracting ..."
    tar xvJf $SRC_PATH/Natron-$SDK_VERSION-Linux-$ARCH-SDK.tar.xz -C $SDK_PATH/ || exit 1
  else
    echo "Need to build SDK ..."
    sh $INC_PATH/scripts/build-sdk.sh || exit 1
  fi
fi

if [ -d $TMP_PATH ]; then
  rm -rf $TMP_PATH || exit 1
fi
mkdir -p $TMP_PATH || exit 1

# Setup env
export PKG_CONFIG_PATH=$INSTALL_PATH/lib/pkgconfig:$INSTALL_PATH/libdata/pkgconfig
export LD_LIBRARY_PATH=$INSTALL_PATH/lib
export PATH=/usr/local/bin:$INSTALL_PATH/bin:$PATH
export QTDIR=$INSTALL_PATH
export BOOST_ROOT=$INSTALL_PATH
export OPENJPEG_HOME=$INSTALL_PATH
export THIRD_PARTY_TOOLS_HOME=$INSTALL_PATH

if [ -d $INSTALL_PATH/Plugins ]; then
  rm -rf $INSTALL_PATH/Plugins || exit 1
fi
mkdir -p $INSTALL_PATH/Plugins || exit 1
rm -rf $INSTALL_PATH/docs/openfx-* || exit 1

if [ -z "$BUILD_IO" ]; then
  BUILD_IO=1
fi
if [ -z "$BUILD_MISC" ]; then
  BUILD_MISC=1
fi
if [ -z "$BUILD_ARENA" ]; then
  BUILD_ARENA=1
fi
if [ -z "$BUILD_CV" ]; then
  BUILD_CV=1
fi

# MISC
if [ "$BUILD_MISC" == "1" ]; then

cd $TMP_PATH || exit 1

if [ -f $SRC_PATH/openfx-misc-$MISC_V.tar.gz ] && [ "$LATEST" != "1" ]; then
  tar xvf $SRC_PATH/openfx-misc-$MISC_V.tar.gz || exit 1
  cd openfx-misc* || exit 1
else
  git clone $GIT_MISC || exit 1
  cd openfx-misc || exit 1
  if [ "$LATEST" == "1" ]; then
    echo "Using latest commit"
    git checkout master || exit 1
    git pull origin master
  else
    git checkout ${MISC_V} || exit 1
  fi
  MISC_GIT_VERSION=$(git log|head -1|awk '{print $2}')
  if [ "$LATEST" == "1" ]; then
    echo "Bumping common.sh with new git commit"
    MISC_V=$MISC_GIT_VERSION
    sed -i "s/MISCPLUG_DEVEL_GIT=.*/MISCPLUG_DEVEL_GIT=${MISC_V}/" $CWD/common.sh || exit 1
  else
    if [ "$MISC_GIT_VERSION" != "$MISC_V" ]; then
      echo "version don't match"
      exit 1
    fi
  fi
  git submodule update -i --recursive || exit 1
  if [ "$NOSRC" != "1" ]; then
    (cd .. ; 
      cp -a openfx-misc openfx-misc-$MISC_GIT_VERSION
      (cd openfx-misc-$MISC_GIT_VERSION ; find . -type d -name .git -exec rm -rf {} \;)
      tar cvvzf $CWD/src/openfx-misc-$MISC_GIT_VERSION.tar.gz openfx-misc-$MISC_GIT_VERSION
    )
  fi
fi

CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" make DEBUGFLAG=-O3 BITS=$BIT || exit 1
cp -a */Linux-$BIT-release/*.ofx.bundle $INSTALL_PATH/Plugins/ || exit 1

mkdir -p $INSTALL_PATH/docs/openfx-misc || exit 1
cp LICENSE README* $INSTALL_PATH/docs/openfx-misc/ || exit 1
echo $MISC_GIT_VERSION > $INSTALL_PATH/docs/openfx-misc/VERSION || exit 1

fi

# IO
if [ "$BUILD_IO" == "1" ]; then

cd $TMP_PATH || exit 1

if [ -f $CWD/src/openfx-io-$IO_V.tar.gz ] && [ "$LATEST" != "1" ]; then
  tar xvf $CWD/src/openfx-io-$IO_V.tar.gz || exit 1
  cd openfx-io* || exit 1
else
  git clone $GIT_IO || exit 1
  cd openfx-io || exit 1
  if [ "$LATEST" == "1" ]; then
    echo "Using latest commit"
    git checkout master || exit 1
    git pull origin master
  else
    git checkout ${IO_V} || exit 1
  fi
  IO_GIT_VERSION=$(git log|head -1|awk '{print $2}')
  if [ "$LATEST" == "1" ]; then
    echo "Bumping common.sh with new git commit"
    IO_V=$IO_GIT_VERSION
    sed -i "s/IOPLUG_DEVEL_GIT=.*/IOPLUG_DEVEL_GIT=${IO_V}/" $CWD/common.sh || exit 1
  else
    if [ "$IO_GIT_VERSION" != "$IO_V" ]; then
      echo "version don't match"
      exit 1
    fi
  fi
  git submodule update -i --recursive || exit 1
  if [ "$NOSRC" != "1" ]; then
    (cd .. ; 
      cp -a openfx-io openfx-io-$IO_GIT_VERSION
      (cd openfx-io-$IO_GIT_VERSION ; find . -type d -name .git -exec rm -rf {} \;)
      tar cvvzf $CWD/src/openfx-io-$IO_GIT_VERSION.tar.gz openfx-io-$IO_GIT_VERSION
    )
  fi
fi

CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" make DEBUGFLAG=-O3 BITS=$BIT || exit 1
cp -a IO/Linux-$BIT-release/IO.ofx.bundle $INSTALL_PATH/Plugins/ || exit 1

mkdir -p $INSTALL_PATH/docs/openfx-io || exit 1
cp LICENSE README* $INSTALL_PATH/docs/openfx-io/ || exit 1
echo $IO_GIT_VERSION > $INSTALL_PATH/docs/openfx-io/VERSION || exit 1

fi

# ARENA
if [ "$BUILD_ARENA" == "1" ]; then

cd $TMP_PATH || exit 1
if [ -f $CWD/src/openfx-arena-$ARENA_V.tar.gz ] && [ "$LATEST" != "1" ]; then
  tar xvf $CWD/src/openfx-arena-$ARENA_V.tar.gz || exit 1
  cd openfx-arena* || exit 1
else
  git clone $GIT_ARENA || exit 1
  cd openfx-arena || exit 1
  if [ "$LATEST" == "1" ]; then
    echo "Using latest commit"
    git checkout master || exit 1
    git pull origin master
  else
    git checkout ${ARENA_V} || exit 1
  fi
  ARENA_GIT_VERSION=$(git log|head -1|awk '{print $2}')
  if [ "$LATEST" == "1" ]; then
    echo "Bumping common.sh with new git commit"
    ARENA_V=$ARENA_GIT_VERSION
    sed -i "s/ARENAPLUG_DEVEL_GIT=.*/ARENAPLUG_DEVEL_GIT=${ARENA_V}/" $CWD/common.sh || exit 1
  else
    if [ "$ARENA_GIT_VERSION" != "$ARENA_V" ]; then
      echo "version don't match"
      exit 1
    fi
  fi
  git submodule update -i --recursive || exit 1
  if [ "$NOSRC" != "1" ]; then
    (cd .. ;
      cp -a openfx-arena openfx-arena-$ARENA_GIT_VERSION
      (cd openfx-arena-$ARENA_GIT_VERSION ; find . -type d -name .git -exec rm -rf {} \;)
      tar cvvzf $CWD/src/openfx-arena-$ARENA_GIT_VERSION.tar.gz openfx-arena-$ARENA_GIT_VERSION
    )
  fi
fi

CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" make USE_SVG=1 USE_PANGO=1 STATIC=1 DEBUGFLAG=-O3 BITS=$BIT || exit 1
cp -a Bundle/Linux-$BIT-release/Arena.ofx.bundle $INSTALL_PATH/Plugins/ || exit 1

mkdir -p $INSTALL_PATH/docs/openfx-arena || exit 1
cp LICENSE README.md $INSTALL_PATH/docs/openfx-arena/ || exit 1
echo $ARENA_V > $INSTALL_PATH/docs/openfx-arena/VERSION || exit 1

fi

# OPENCV
if [ "$BUILD_CV" == "1" ]; then

cd $TMP_PATH || exit 1
if [ -f $CWD/src/openfx-opencv-$CV_V.tar.gz ] && [ "$LATEST" != "1" ]; then
  tar xvf $CWD/src/openfx-opencv-$CV_V.tar.gz || exit 1
  cd openfx-opencv* || exit 1
else
  git clone $GIT_OPENCV || exit 1
  cd openfx-opencv || exit 1
  if [ "$LATEST" == "1" ]; then
    echo "Using latest commit"
    git checkout master || exit 1
    git pull origin master
  else
    git checkout ${CV_V} || exit 1
  fi
  CV_GIT_VERSION=$(git log|head -1|awk '{print $2}')
  if [ "$LATEST" == "1" ]; then
    echo "Bumping common.sh with new git commit"
    CV_V=$CV_GIT_VERSION
    sed -i "s/CVPLUG_DEVEL_GIT=.*/CVPLUG_DEVEL_GIT=${CV_V}/" $CWD/common.sh || exit 1
  else
    if [ "$CV_GIT_VERSION" != "$CV_V" ]; then
      echo "version don't match"
      exit 1
    fi
  fi
  git submodule update -i --recursive || exit 1
  if [ "$NOSRC" != "1" ]; then
    (cd .. ;
      cp -a openfx-opencv openfx-opencv-$CV_GIT_VERSION
      (cd openfx-opencv-$CV_GIT_VERSION ; find . -type d -name .git -exec rm -rf {} \;)
      tar cvvzf $CWD/src/openfx-opencv-$CV_GIT_VERSION.tar.gz openfx-opencv-$CV_GIT_VERSION
    )
  fi
fi

cd opencv2fx || exit 1
CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" make DEBUGFLAG=-O3 BITS=$BIT || exit 1
cp -a */Linux-$BIT-release/*.ofx.bundle $INSTALL_PATH/Plugins/ || exit 1

mkdir -p $INSTALL_PATH/docs/openfx-opencv || exit 1
cp LIC* READ* $INSTALL_PATH/docs/openfx-opencv/ 
echo $CV_V > $INSTALL_PATH/docs/openfx-opencv/VERSION || exit 1

fi

echo "Done!"
