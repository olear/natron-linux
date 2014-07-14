#!/bin/sh
#
# Written by Ole Andre Rodlie <olear@dracolinux.org>
#

gcc -v
sleep 5

# Dist files
GIT_IO=https://github.com/MrKepzie/openfx-io.git
GIT_MISC=https://github.com/devernay/openfx-misc.git
GIT_YADIF=https://github.com/devernay/openfx-yadif.git
GIT_CV=https://github.com/devernay/openfx-opencv.git

# Natron version
IO_V=0b3fb8a0e0779b4a8d5d43a03f82738485295691 
MISC_V=b6ebbb648d64c5ec2d9ffab4a77246b9e881c90b
YADIF_V=4fe05af2d5382a5e10a6e7f65e1103d2f67421f9
CV_V=80dc18f9dcfb16632d3083c7cc63a8ac1dad285d

SDK_VERSION=0.9

# Threads
MKJOBS=4

# Setup
CWD=$(pwd)
INSTALL_PATH=/opt/Natron-$SDK_VERSION
TMP_PATH=$CWD/tmp

if [ ! -d $TMP_PATH ]; then
  mkdir -p $TMP_PATH || exit 1
else
  rm -rf $TMP_PATH || exit 1
  mkdir -p $TMP_PATH || exit 1
fi

# Setup env
export PKG_CONFIG_PATH=$INSTALL_PATH/lib/pkgconfig
export LD_LIBRARY_PATH=$INSTALL_PATH/lib
export PATH=/usr/local/bin:$INSTALL_PATH/bin:$PATH
export QTDIR=$INSTALL_PATH
export BOOST_ROOT=$INSTALL_PATH
export OPENJPEG_HOME=$INSTALL_PATH
export THIRD_PARTY_TOOLS_HOME=$INSTALL_PATH
export PYTHON_HOME=$INSTALL_PATH
export PYTHON_PATH=$INSTALL_PATH/lib/python2.7

# Install essential plugins
mkdir -p $INSTALL_PATH/Plugins || exit 1

cd $TMP_PATH || exit 1

git clone $GIT_MISC || exit 1
cd openfx-misc || exit 1
git checkout ${MISC_V} || exit 1
MISC_GIT_VERSION=$(git log|head -1|awk '{print $2}')
if [ "$MISC_GIT_VERSION" != "$MISC_V" ]; then
  echo "version don't match"
  exit 1
fi
git submodule update -i --recursive || exit 1

(cd .. ; 
  cp -a openfx-misc openfx-misc-$MISC_GIT_VERSION
  (cd openfx-misc-$MISC_GIT_VERSION ; find . -type d -name .git -exec rm -rf {} \;)
  tar cvvzf $CWD/src/openfx-misc-$MISC_GIT_VERSION.tar.gz openfx-misc-$MISC_GIT_VERSION
)

CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" make DEBUGFLAG=-O3 BITS=64 || exit 1
cp -a Misc/Linux-64-release/Misc.ofx.bundle $INSTALL_PATH/Plugins/ || exit 1
mkdir -p $INSTALL_PATH/docs/openfx-misc || exit 1
cp LICENSE README* $INSTALL_PATH/docs/openfx-misc/ || exit 1
echo $MISC_GIT_VERSION > $INSTALL_PATH/docs/openfx-misc/VERSION || exit 1

cd $TMP_PATH || exit 1

git clone $GIT_IO || exit 1
cd openfx-io || exit 1
git checkout ${IO_V} || exit 1
IO_GIT_VERSION=$(git log|head -1|awk '{print $2}')
if [ "$IO_GIT_VERSION" != "$IO_V" ]; then
  echo "version don't match"
  exit 1
fi
git submodule update -i --recursive || exit 1

(cd .. ; 
  cp -a openfx-io openfx-io-$IO_GIT_VERSION
  (cd openfx-io-$IO_GIT_VERSION ; find . -type d -name .git -exec rm -rf {} \;)
  tar cvvzf $CWD/src/openfx-io-$IO_GIT_VERSION.tar.gz openfx-io-$IO_GIT_VERSION
)

CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" make DEBUGFLAG=-O3 BITS=64 || exit 1
cp -a IO/Linux-64-release/IO.ofx.bundle $INSTALL_PATH/Plugins/ || exit 1
mkdir -p $INSTALL_PATH/docs/openfx-io || exit 1
cp LICENSE README* $INSTALL_PATH/docs/openfx-io/ || exit 1
echo $IO_GIT_VERSION > $INSTALL_PATH/docs/openfx-io/VERSION || exit 1

# YADIF
cd $TMP_PATH || exit 1
git clone $GIT_YADIF || exit 1
cd openfx-yadif || exit 1
git checkout ${YADIF_V} || exit 1
YADIF_GIT_VERSION=$(git log|head -1|awk '{print $2}')
if [ "$YADIF_GIT_VERSION" != "$YADIF_V" ]; then
  echo "version don't match"
  exit 1
fi
git submodule update -i --recursive || exit 1
(cd .. ;
  cp -a openfx-yadif openfx-yadif-$YADIF_GIT_VERSION
  (cd openfx-yadif-$YADIF_GIT_VERSION ; find . -type d -name .git -exec rm -rf {} \;)
  tar cvvzf $CWD/src/openfx-yadif-$YADIF_GIT_VERSION.tar.gz openfx-yadif-$YADIF_GIT_VERSION
)
CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" make DEBUGFLAG=-O3 BITS=64 || exit 1
cp -a Linux-64-release/*.ofx.bundle $INSTALL_PATH/Plugins/ || exit 1
mkdir -p $INSTALL_PATH/docs/openfx-yadif || exit 1
cp LICENSE README* $INSTALL_PATH/docs/openfx-yadif/
echo $YADIF_GIT_VERSION > $INSTALL_PATH/docs/openfx-yadif/VERSION || exit 1

# OpenCV
cd $TMP_PATH || exit 1
git clone $GIT_CV || exit 1
cd openfx-opencv || exit 1
git checkout ${CV_V} || exit 1
CV_GIT_VERSION=$(git log|head -1|awk '{print $2}')
if [ "$CV_GIT_VERSION" != "$CV_V" ]; then
  echo "version don't match"
  exit 1
fi
git submodule update -i --recursive || exit 1

(cd .. ;
  cp -a openfx-opencv openfx-opencv-$CV_GIT_VERSION
  (cd openfx-opencv-$CV_GIT_VERSION ; find . -type d -name .git -exec rm -rf {} \;)
  tar cvvzf $CWD/src/openfx-opencv-$CV_GIT_VERSION.tar.gz openfx-opencv-$CV_GIT_VERSION
)
cd opencv2fx || exit 1
CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" make DEBUGFLAG=-O3 BITS=64 || exit 1
cp -a */Linux-64-release/*.ofx.bundle $INSTALL_PATH/Plugins/ || exit 1
mkdir -p $INSTALL_PATH/docs/openfx-opencv || exit 1
cp LICENSE README* $INSTALL_PATH/docs/openfx-opencv/
echo $CV_GIT_VERSION > $INSTALL_PATH/docs/openfx-opencv/VERSION || exit 1

echo "Done!"
