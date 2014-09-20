#!/bin/sh
#
# Build Natron for Linux/FreeBSD/Win32
# Written by Ole Andre Rodlie <olear@dracolinux.org>
#

GIT_NATRON=https://github.com/MrKepzie/Natron.git

if [ "$1" == "workshop" ];then
NATRON_REL_V=$(cat NATRON_WORKSHOP)
else
NATRON_REL_V=$(cat NATRON_RELEASE)
fi

NATRON_REL_B=workshop
SDK_VERSION=1.0

# Threads
if [ -z "$MKJOBS" ]; then
  MKJOBS=4
fi

# Setup
if [ -z "$ARCH" ]; then
  case "$( uname -m )" in
    i?86) export ARCH=i686 ;;
    amd64) export ARCH=x86_64 ;;
       *) export ARCH=$( uname -m ) ;;
  esac
fi
if [ "$ARCH" = "i686" ]; then
  BF="-O2 -march=i686 -mtune=i686"
elif [ "$ARCH" = "x86_64" ]; then
  BF="-O2 -fPIC"
else
  BF="-O2"
fi
OS=$(uname -o)
CWD=$(pwd)

if [ "$OS" == "GNU/Linux" ]; then
  INSTALL_PATH=/opt/Natron-$SDK_VERSION
else
  INSTALL_PATH=/usr/local
fi

if [ "$OS" == "Msys" ]; then
  rm -rf $INSTALL_PATH
  mkdir -p $INSTALL_PATH/bin || exit 1
  mkdir -p $INSTALL_PATH/share || exit 1
fi

TMP_PATH=$CWD/tmp

if [ -d $TMP_PATH ]; then
  rm -rf $TMP_PATH || exit 1
fi
mkdir -p $TMP_PATH || exit 1
mkdir -p $CWD/src

if [ "$OS" == "GNU/Linux" ]; then
  gcc -v
  sleep 5
fi

# Setup env
if [ "$OS" != "Msys" ]; then
export PKG_CONFIG_PATH=$INSTALL_PATH/lib/pkgconfig:$INSTALL_PATH/libdata/pkgconfig
export LD_LIBRARY_PATH=$INSTALL_PATH/lib
export PATH=/usr/local/bin:$INSTALL_PATH/bin:$PATH
export QTDIR=$INSTALL_PATH
export BOOST_ROOT=$INSTALL_PATH
fi

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

if [ "$OS" == "GNU/Linux" ]; then
(cd .. ;
  cp -a Natron Natron-$REL_GIT_VERSION
  (cd Natron-$REL_GIT_VERSION ; find . -type d -name .git -exec rm -rf {} \;)
  tar cvvzf $CWD/src/Natron-$REL_GIT_VERSION.tar.gz Natron-$REL_GIT_VERSION
)
fi

cat $CWD/installer/GitVersion.h | sed "s#__BRANCH__#${NATRON_REL_B}#;s#__COMMIT__#${REL_GIT_VERSION}#" > Global/GitVersion.h || exit 1

if [ "$OS" == "GNU/Linux" ]; then
  cat $CWD/installer/config.pri > config.pri || exit 1
fi

if [ "$OS" == "FreeBSD" ]; then
  cat $CWD/installer/config-freebsd.pri > config.pri || exit 1
fi

if [ "$OS" == "Msys" ]; then
  cat $CWD/installer/config-win.pri > config.pri || exit 1
fi

# Stylefix for Linux
if [ "$OS" == "GNU/Linux" ]; then
  patch -p0< $CWD/patches/stylefix.diff || exit 1
fi

if [ "$OS" != "Msys" ]; then
rm -rf build
mkdir build || exit 1
cd build || exit 1
fi

if [ "$OS" == "FreeBSD" ]; then
CXX=clang++ CC=clang CFLAGS="$BF" CXXFLAGS="-std=c++11 $BF" $INSTALL_PATH/bin/qmake-qt4 -r CONFIG+=release DEFINES+=QT_NO_DEBUG_OUTPUT ../Project.pro || exit 1
fi

if [ "$OS" == "GNU/Linux" ]; then
CFLAGS="$BF" CXXFLAGS="$BF" $INSTALL_PATH/bin/qmake -r CONFIG+=release DEFINES+=QT_NO_DEBUG_OUTPUT ../Project.pro || exit 1
fi

if [ "$OS" == "Msys" ]; then
  cp $CWD/installer/qmake-win32.bat . || exit 1
  cp $CWD/installer/vcbuild-win32.bat . || exit 1
  cmd //c qmake-win32.bat || exit 1
  #patch -p0< $CWD/patches/link-win32.diff || exit 1
  cat App/Natron.vcxproj | sed 's#<AdditionalDependencies>#<AdditionalDependencies>C:\\local\\cairo-1.12\\lib\\x86\\cairo.lib\;C:\\local\\expat-2.0.1\\win32\\bin\\Release\\libexpatMT.lib\;C:\\local\\glew-1.11.0\\lib\\Release\\Win32\\glew32.lib\;C:\\local\\boost_1_55_0\\lib32-msvc-10.0\\boost_serialization-vc100-mt-1_55.lib\;#;s#<AdditionalLibraryDirectories>#<AdditionalLibraryDirectories>C:\\local\\cairo-1.12\\lib\\x86\;C:\\local\\expat-2.0.1\\win32\\bin\\Release\;C:\\local\\glew-1.11.0\\lib\\Release\\Win32\;C:\\local\\boost_1_55_0\\lib32-msvc-10.0\;#' > App/Natron.vcxproj.new || exit 1
  mv App/Natron.vcxproj.new App/Natron.vcxproj || exit 1
  cmd //c vcbuild-win32.bat || exit 1
else
  make -j${MKJOBS} || exit 1
fi

if [ "$OS" == "Msys" ]; then
  cp App/win32/release/Natron.exe $INSTALL_PATH/bin/ || exit 1
  # Where is NatronRenderer?
else
  cp App/Natron $INSTALL_PATH/bin/ || exit 1
  cp Renderer/NatronRenderer $INSTALL_PATH/bin/ || exit 1
fi

if [ "$OS" == "Msys" ]; then
  cp -a Gui/Resources/OpenColorIO-Configs $INSTALL_PATH/share/ || exit 1
  mkdir -p $INSTALL_PATH/docs/natron || exit 1
  cp LICENSE.txt README* BUGS* CONTRI* Documentation/* $INSTALL_PATH/docs/natron/ || exit 1
  echo "done!"
  exit 0
fi

rm -rf * || exit 1

if [ "$OS" == "FreeBSD" ]; then
CXX=clang++ CC=clang CFLAGS="$BF" CXXFLAGS="-std=c++11 $BF" $INSTALL_PATH/bin/qmake-qt4 -r CONFIG+=debug ../Project.pro || exit 1
else
CFLAGS="$BF" CXXFLAGS="$BF" $INSTALL_PATH/bin/qmake -r CONFIG+=debug ../Project.pro || exit 1
fi

make -j${MKJOBS} || exit 1
cp App/Natron $INSTALL_PATH/bin/Natron.debug || exit 1
cp Renderer/NatronRenderer $INSTALL_PATH/bin/NatronRenderer.debug || exit 1

cp -a ../Gui/Resources/OpenColorIO-Configs $INSTALL_PATH/share/ || exit 1
mkdir -p $INSTALL_PATH/docs/natron || exit 1
cp ../LICENSE.txt ../README* ../BUGS* ../CONTRI* ../Documentation/* $INSTALL_PATH/docs/natron/ || exit 1
mkdir -p $INSTALL_PATH/share/pixmaps || exit 1
cp ../Gui/Resources/Images/natronIcon256_linux.png $INSTALL_PATH/share/pixmaps/ || exit 1
echo "Done!"

