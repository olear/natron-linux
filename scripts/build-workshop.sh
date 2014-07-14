#!/bin/sh
#
# Written by Ole Andre Rodlie <olear@dracolinux.org>
#

gcc -v
sleep 5

# Dist files
GIT_NATRON=https://github.com/MrKepzie/Natron.git

# Natron version
NATRON_REL_V=aa5dbb0cbb888fedcba8ce3851815cd5d7019261
NATRON_REL_B=workshop
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

# Install natron
cd $TMP_PATH || exit 1

git clone $GIT_NATRON || exit 1
cd Natron || exit 1

git checkout ${NATRON_REL_V} || exit 1
REL_GIT_VERSION=$(git log|head -1|awk '{print $2}')
if [ "$NATRON_REL_V" != "$REL_GIT_VERSION" ]; then
  echo "version mismatch: $NATRON_REL_V vs. $REL_GIT_VERSION"
  exit 1
fi

git submodule update -i --recursive || exit 1

(cd .. ;
  cp -a Natron Natron-$REL_GIT_VERSION
  (cd Natron-$REL_GIT_VERSION ; find . -type d -name .git -exec rm -rf {} \;)
  tar cvvzf $CWD/src/Natron-$REL_GIT_VERSION.tar.gz Natron-$REL_GIT_VERSION
)

cat $CWD/installer/GitVersion.h | sed "s#__BRANCH__#${NATRON_REL_B}#;s#__COMMIT__#${REL_GIT_VERSION}#" > Global/GitVersion.h || exit 1
cat $CWD/installer/config.pri > config.pri || exit 1
patch -p0< $CWD/patches/stylefix.diff || exit 1
#patch -p0< $CWD/patches/ocio-path.diff || exit 1
mkdir build || exit 1
cd build || exit 1

$INSTALL_PATH/bin/qmake -r CONFIG+=release DEFINES+=QT_NO_DEBUG_OUTPUT ../Project.pro || exit 1
make -j${MKJOBS} || exit 1

cp App/Natron $INSTALL_PATH/bin/NatronWS || exit 1
cp Renderer/NatronRenderer $INSTALL_PATH/bin/NatronRendererWS || exit 1

rm -rf * || exit 1
$INSTALL_PATH/bin/qmake -r CONFIG+=debug ../Project.pro || exit 1
make -j${MKJOBS} || exit 1
cp App/Natron $INSTALL_PATH/bin/NatronWS.debug || exit 1
cp Renderer/NatronRenderer $INSTALL_PATH/bin/NatronRendererWS.debug || exit 1