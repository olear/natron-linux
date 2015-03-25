#!/bin/sh
#
# Build Natron for Linux and FreeBSD.
# Written by Ole-André Rodlie <olear@fxarena.net>
#

source $(pwd)/common.sh || exit 1
NATRON_BRANCH=$1
if [ "$NATRON_BRANCH" == "" ]; then
  NATRON_BRANCH=master
fi

if [ "$NATRON_BRANCH" == "workshop" ]; then
  NATRON_REL_V=$NATRON_DEVEL_GIT
else
  NATRON_REL_V=$NATRON_STABLE_GIT
fi

if [ "$NATRON_REL_V" == "" ]; then
  echo "No git version defined, please check common.sh."
  exit 1
fi

if [ "$OS" != "GNU/Linux" ]; then
  INSTALL_PATH=/usr/local
else
  if [ ! -d $INSTALL_PATH ]; then
    if [ -f $SRC_PATH/Natron-$SDK_VERSION-Linux-$ARCH-SDK.tar.xz ]; then
      echo "Found binary SDK, extracting ..."
      tar xvJf $SRC_PATH/Natron-$SDK_VERSION-Linux-$ARCH-SDK.tar.xz -C $SDK_PATH/ || exit 1
    else
      echo "Need to build SDK ..."
      sh $CWD/installer/scripts/build-sdk.sh || exit 1
    fi
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
export PYTHON_HOME=$INSTALL_PATH
export PYTHON_PATH=$INSTALL_PATH/lib/python3.4
export PYTHON_INCLUDE=$INSTALL_PATH/include/python3.4

echo
echo "Building Natron $NATRON_REL_V from $NATRON_BRANCH against SDK $SDK_VERSION on $ARCH using $MKJOBS threads."
echo
sleep 5

# Install natron
cd $TMP_PATH || exit 1

if [ -f $SRC_PATH/Natron-$NATRON_REL_V.tar.gz ]; then
  tar xvf $SRC_PATH/Natron-$NATRON_REL_V.tar.gz || exit 1
  cd Natron* || exit 1
else
  git clone $GIT_NATRON || exit 1
  cd Natron || exit 1
  git checkout $NATRON_REL_V || exit 1
  REL_GIT_VERSION=$(git log|head -1|awk '{print $2}')
  if [ "$NATRON_REL_V" != "$REL_GIT_VERSION" ]; then
    echo "version mismatch: $NATRON_REL_V vs. $REL_GIT_VERSION"
    exit 1
  fi
  git submodule update -i --recursive || exit 1
  if [ "$NOSRC" != "1" ]; then
    (cd .. ;
      cp -a Natron Natron-$REL_GIT_VERSION
      (cd Natron-$REL_GIT_VERSION ; find . -type d -name .git -exec rm -rf {} \;)
      (cd Natron-$REL_GIT_VERSION/Gui/Resources/OpenColorIO-Configs ; find . -type d -name .git -exec rm -rf {} \;)
      tar cvvzf $SRC_PATH/Natron-$REL_GIT_VERSION.tar.gz Natron-$REL_GIT_VERSION
    )
  fi
fi

cat $CWD/installer/natron/GitVersion.h | sed "s#__BRANCH__#${NATRON_BRANCH}#;s#__COMMIT__#${REL_GIT_VERSION}#" > Global/GitVersion.h || exit 1

if [ "$OS" == "GNU/Linux" ]; then
  cat $CWD/installer/natron/config.pri > config.pri || exit 1
else
  cat $CWD/installer/natron/config-freebsd.pri > config.pri || exit 1
fi

rm -rf build
mkdir build || exit 1
cd build || exit 1

if [ "$OS" == "FreeBSD" ]; then
CXX=clang++ CC=clang CFLAGS="$BF" CXXFLAGS="-std=c++11 $BF" $INSTALL_PATH/bin/qmake-qt4 -r CONFIG+=release DEFINES+=QT_NO_DEBUG_OUTPUT ../Project.pro || exit 1
else
CFLAGS="$BF" CXXFLAGS="$BF" $INSTALL_PATH/bin/qmake -r CONFIG+=release DEFINES+=QT_NO_DEBUG_OUTPUT ../Project.pro || exit 1
fi

make -j${MKJOBS} || exit 1

cp App/Natron $INSTALL_PATH/bin/ || exit 1
cp Renderer/NatronRenderer $INSTALL_PATH/bin/ || exit 1
if [ "$NATRON_BRANCH" == "workshop" ] && [ "$OS" == "GNU/Linux" ]; then
  cp CrashReporter/NatronCrashReporter $INSTALL_PATH/bin/ || exit 1
fi

rm -rf * || exit 1

if [ "$NODEBUG" == "" ]; then
if [ "$OS" == "FreeBSD" ]; then
CXX=clang++ CC=clang CFLAGS="$BF" CXXFLAGS="-std=c++11 $BF" $INSTALL_PATH/bin/qmake-qt4 -r CONFIG+=debug ../Project.pro || exit 1
else
CFLAGS="$BF" CXXFLAGS="$BF" $INSTALL_PATH/bin/qmake -r CONFIG+=debug ../Project.pro || exit 1
fi

make -j${MKJOBS} || exit 1
cp App/Natron $INSTALL_PATH/bin/Natron.debug || exit 1
cp Renderer/NatronRenderer $INSTALL_PATH/bin/NatronRenderer.debug || exit 1
if [ "$NATRON_BRANCH" == "workshop" ] && [ "$OS" == "GNU/Linux" ]; then
  cp CrashReporter/NatronCrashReporter $INSTALL_PATH/bin/NatronCrashReporter.debug || exit 1
fi
fi

cp -a ../Gui/Resources/OpenColorIO-Configs $INSTALL_PATH/share/ || exit 1
mkdir -p $INSTALL_PATH/docs/natron || exit 1
cp ../LICENSE.txt ../README* ../BUGS* ../CONTRI* ../Documentation/* $INSTALL_PATH/docs/natron/
mkdir -p $INSTALL_PATH/share/pixmaps || exit 1
cp ../Gui/Resources/Images/natronIcon256_linux.png $INSTALL_PATH/share/pixmaps/ || exit 1
echo $NATRON_REL_V > $INSTALL_PATH/docs/natron/VERSION || exit 1

echo "Done!"

