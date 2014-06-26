#!/bin/sh
#
# Build Natron for Linux64 (using CentOS 6.2)
# Written by Ole Andre Rodlie <olear@dracolinux.org>
#

gcc -v
sleep 5

# Dist files
YASM_TAR=yasm-1.2.0.tar.gz
CMAKE_TAR=cmake-2.8.12.2.tar.gz
#PY_TAR=Python-2.7.7.tar.xz
JPG_TAR=jpegsrc.v9a.tar.gz
OJPG_TAR=openjpeg-1.5.1.tar.gz
PNG_TAR=libpng-1.2.51.tar.xz
TIF_TAR=tiff-4.0.3.tar.gz
#LCMS_TAR=lcms2-2.1.tar.gz
ILM_TAR=ilmbase-2.1.0.tar.gz
EXR_TAR=openexr-2.1.0.tar.gz
GLEW_TAR=glew-1.5.5.tgz
BOOST_TAR=boost_1_55_0.tar.bz2
CAIRO_TAR=cairo-1.12.0.tar.gz
FFMPEG_TAR=ffmpeg-2.2.3.tar.bz2
QT4_TAR=qt-everywhere-opensource-src-4.8.6.tar.gz
QT_TAR=qt-everywhere-opensource-src-5.3.0.tar.gz
OCIO_TAR=imageworks-OpenColorIO-v1.0.8-0-g19ed2e3.tar.gz
OIIO_TAR=oiio-Release-1.4.9.tar.gz
IO_TAR=openfx-io-20140626.tar.gz
MISC_TAR=openfx-misc-20140626.tar.gz
NATRON_TAR=Natron-20140626.tar.gz

# Natron version
VERSION=0.9.4
RELEASE=1

# Threads
MKJOBS=4

# Get RHEL version (used when building on rhel5)
if [ -f /etc/redhat-release ]; then
  RHEL=$(cat /etc/redhat-release | awk '{print $3}' | sed 's/\..*//')
fi

# Setup
CWD=$(pwd)
INSTALL_PATH=/opt/Natron-$VERSION
TMP_PATH=$CWD/tmp

if [ ! -d $INSTALL_PATH ]; then
  mkdir -p $INSTALL_PATH || exit 1
else
  rm -rf $INSTALL_PATH || exit 1
  mkdir -p $INSTALL_PATH || exit 1
fi

if [ ! -d $TMP_PATH ]; then
  mkdir -p $TMP_PATH || exit 1
else
  rm -rf $TMP_PATH || exit 1
  mkdir -p $TMP_PATH || exit 1
fi

# Install yasm (needed by ffmpeg)
if [ ! -f /usr/local/bin/yasm ]; then
  cd $TMP_PATH || exit 1
  tar xvf $CWD/src/$YASM_TAR || exit 1
  cd yasm* || exit 1
  ./configure --prefix=/usr/local || exit 1
  make -j${MKJOBS} || exit 1
  make install || exit 1
fi

# Install cmake (needed by openjpeg and oico/oiio)
if [ ! -f /usr/local/bin/cmake ]; then
  cd $TMP_PATH || exit 1
  tar xvf $CWD/src/$CMAKE_TAR || exit 1
  cd cmake* || exit 1
  ./configure --prefix=/usr/local || exit 1
  make -j${MKJOBS} || exit 1
  make install || exit 1
fi

if [ "$1" == "tools" ]; then
  echo "Stopped after $1"
  exit 0
fi

# Setup env
export PKG_CONFIG_PATH=$INSTALL_PATH/lib/pkgconfig
export LD_LIBRARY_PATH=$INSTALL_PATH/lib
export PATH=/usr/local/bin:$INSTALL_PATH/bin:$PATH
export QTDIR=$INSTALL_PATH
export BOOST_ROOT=$INSTALL_PATH
export OPENJPEG_HOME=$INSTALL_PATH
export THIRD_PARTY_TOOLS_HOME=$INSTALL_PATH

# Install jpeg
cd $TMP_PATH || exit 1
tar xvf $CWD/src/$JPG_TAR || exit 1
cd jpeg* || exit 1
./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/jpeg || exit 1
cp LIC* COP* READ* AUTH* CONT* $INSTALL_PATH/docs/jpeg/

if [ "$1" == "jpeg" ]; then
  echo "Stopped after $1"
  exit 0
fi

# Install openjpeg
cd $TMP_PATH || exit 1
tar xvf $CWD/src/$OJPG_TAR || exit 1
cd openjpeg* || exit 1
mkdir build || exit 1
cd build || exit 1
CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH .. || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/openjpeg || exit 1
cp ../LIC* ../COP* ../READ* ../AUTH* ../CONT* $INSTALL_PATH/docs/openjpeg/

if [ "$1" == "openjpeg" ]; then
  echo "Stopped after $1"
  exit 0
fi

# Install png
cd $TMP_PATH || exit 1
tar xvf $CWD/src/$PNG_TAR || exit 1
cd libpng* || exit 1
CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/png || exit 1
cp LIC* COP* README AUTH* CONT* $INSTALL_PATH/docs/png/

if [ "$1" == "png" ]; then
  echo "Stopped after $1"
  exit 0
fi

# Install tiff
cd $TMP_PATH || exit 1
tar xvf $CWD/src/$TIF_TAR || exit 1
cd tiff* || exit 1
CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/tiff || exit 1
cp LIC* COP* README AUTH* CONT* $INSTALL_PATH/docs/tiff/

if [ "$1" == "tiff" ]; then
  echo "Stopped after $1"
  exit 0
fi

# Install lcms
# ocio has an internal copy, use that (cmake uses that anyway)
#cd $TMP_PATH || exit 1
#tar xvf $CWD/src/$LCMS_TAR || exit 1
#cd lcms* || exit 1
#CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --disable-static || exit 1
#make -j${MKJOBS} || exit 1
#make install || exit 1
#mkdir -p $INSTALL_PATH/docs/lcms || exit 1
#cp LIC* COP* README AUTH* CONT* $INSTALL_PATH/docs/lcms/

#if [ "$1" == "lcms" ]; then
#  echo "Stopped after $1"
#  exit 0
#fi

# Install openexr
cd $TMP_PATH || exit 1
tar xvf $CWD/src/$ILM_TAR || exit 1
cd ilmbase* || exit 1
CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/openexr || exit 1
cp LIC* COP* README AUTH* CONT* $INSTALL_PATH/docs/openexr/

cd $TMP_PATH || exit 1
tar xvf $CWD/src/$EXR_TAR || exit 1
cd openexr* || exit 1
CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
cp LIC* COP* README AUTH* CONT* $INSTALL_PATH/docs/openexr/

if [ "$1" == "openexr" ]; then
  echo "Stopped after $1"
  exit 0
fi

# Install glew
cd $TMP_PATH || exit 1
tar xvf $CWD/src/$GLEW_TAR || exit 1
cd glew* || exit 1
patch -p1< $CWD/glew-1.5.2-add-needed.patch || exit 1
patch -p1< $CWD/glew-1.5.2-makefile.patch || exit 1
sed -i -e 's/\r//g' config/config.guess || exit 1
make -j${MKJOBS} 'CFLAGS.EXTRA=-O2 -g -m64 -mtune=generic' includedir=/usr/include GLEW_DEST= libdir=/usr/lib64 bindir=/usr/bin || exit 1
make install GLEW_DEST=$INSTALL_PATH libdir=/lib bindir=/bin includedir=/include || exit 1
mkdir -p $INSTALL_PATH/docs/glew || exit 1
cp LICENSE.txt README.txt $INSTALL_PATH/docs/glew/ || exit 1

if [ "$1" == "glew" ]; then
  echo "Stopped after $1"
  exit 0
fi

# Install cairo
cd $TMP_PATH || exit 1
tar xvf $CWD/src/$CAIRO_TAR || exit 1
cd cairo* || exit 1
CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/cairo || exit 1
cp COPYING* README AUTHORS $INSTALL_PATH/docs/cairo/ || exit 1

if [ "$1" == "cairo" ]; then
  echo "Stopped after $1"
  exit 0
fi

# Install ffmpeg
cd $TMP_PATH || exit 1
tar xvf $CWD/src/$FFMPEG_TAR || exit 1
cd ffmpeg* || exit 1
CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/ffmpeg || exit 1
cp LICENSE COPYING.LGPLv2.1 README MAINTAINERS CREDITS $INSTALL_PATH/docs/ffmpeg/ || exit 1

if [ "$1" == "ffmpeg" ]; then
  echo "Stopped after $1"
  exit 0
fi

# Install boost
cd $TMP_PATH || exit 1
tar xvf $CWD/src/$BOOST_TAR || exit 1
cd boost* || exit 1
./bootstrap.sh || exit 1
./b2 -j${MKJOBS} --disable-icu || exit 1
./b2 install --prefix=$INSTALL_PATH || exit 1
mkdir -p $INSTALL_PATH/docs/boost || exit 1
cp LICENSE_1_0.txt $INSTALL_PATH/docs/boost/ || exit 1

if [ "$1" == "boost" ]; then
  echo "Stopped after $1"
  exit 0
fi

# Install ocio
cd $TMP_PATH || exit 1
tar xvf $CWD/src/$OCIO_TAR || exit 1
cd imagework* || exit 1
mkdir build || exit 1
cd build || exit 1
# -DUSE_EXTERNAL_LCMS=OFF
#CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" cmake .. -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH -DCMAKE_BUILD_TYPE=Release -DOCIO_BUILD_JNIGLUE=OFF -DOCIO_BUILD_NUKE=OFF -DOCIO_BUILD_SHARED=ON -DOCIO_BUILD_STATIC=OFF -DOCIO_STATIC_JNIGLUE=OFF -DUSE_EXTERNAL_LCMS=ON -DOCIO_BUILD_TRUELIGHT=OFF -DUSE_EXTERNAL_TINYXML=OFF -DUSE_EXTERNAL_YAML=OFF -DOCIO_BUILD_APPS=OFF -DOCIO_USE_BOOST_PTR=ON -DOCIO_BUILD_TESTS=OFF -DOCIO_BUILD_PYGLUE=OFF
CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" cmake .. -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH -DCMAKE_BUILD_TYPE=Release -DOCIO_BUILD_SHARED=ON -DOCIO_BUILD_STATIC=OFF || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/ocio || exit 1
cp ../LICENSE ../README $INSTALL_PATH/docs/ocio/ || exit 1

if [ "$1" == "ocio" ]; then
  echo "Stopped after $1"
  exit 0
fi

# Install oiio
cd $TMP_PATH || exit 1
tar xvf $CWD/src/$OIIO_TAR || exit 1
cd oiio* || exit 1
patch -p0< $CWD/stupid_cmake.diff || exit 1
patch -p0< $CWD/stupid_cmake_again.diff || exit 1
mkdir build || exit 1
cd build || exit 1
CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" CXXFLAGS="-fPIC" cmake USE_OPENSSL=0 OPENJPEG_HOME=$INSTALL_PATH OPENJPEG_INCLUDE_DIR=$INSTALL_PATH/include/openjpeg-2.0 THIRD_PARTY_TOOLS_HOME=$INSTALL_PATH USE_QT=0 USE_TBB=0 USE_PYTHON=0 USE_FIELD3D=0 USE_OPENJPEG=1 USE_OCIO=1 OIIO_BUILD_TESTS=0 OIIO_BUILD_TOOLS=0 OCIO_HOME=$INSTALL_PATH -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH .. || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/oiio || exit 1
cp ../LICENSE ../README* ../CREDITS $INSTALL_PATH/docs/oiio || exit 1

if [ "$1" == "oiio" ]; then
  echo "Stopped after $1"
  exit 0
fi

# Install essential plugins
mkdir -p $INSTALL_PATH/Plugins || exit 1

cd $TMP_PATH || exit 1
tar xvf $CWD/src/$MISC_TAR || exit 1
cd openfx-misc* || exit 1
CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" make DEBUGFLAG=-O3 BITS=64 || exit 1
cp -a Misc/Linux-64-release/Misc.ofx.bundle $INSTALL_PATH/Plugins/ || exit 1
mkdir -p $INSTALL_PATH/docs/openfx-misc || exit 1
cp LICENSE README* $INSTALL_PATH/docs/openfx-misc/ || exit 1

cd $TMP_PATH || exit 1
tar xvf $CWD/src/$IO_TAR || exit 1
cd openfx-io* || exit 1
CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" make DEBUGFLAG=-O3 BITS=64 || exit 1
cp -a IO/Linux-64-release/IO.ofx.bundle $INSTALL_PATH/Plugins/ || exit 1
mkdir -p $INSTALL_PATH/docs/openfx-io || exit 1
cp LICENSE README* $INSTALL_PATH/docs/openfx-io/ || exit 1

if [ "$1" == "plugins" ]; then
  echo "Stopped after $1"
  exit 0
fi

# Install qt (v5 is known to work, v4 don't)
cd $TMP_PATH || exit 1
QT_CONF="-opensource -nomake examples -nomake tests -release -no-gtkstyle -confirm-license -no-c++11 -I${INSTALL_PATH}/include -L${INSTALL_PATH}/lib"

if [ "$1" == "qt4" ];then
  QT_TAR=$QT4_TAR
  QT_CONF="-confirm-license -release -opensource -opengl -nomake demos -nomake docs -nomake examples -no-webkit"
fi

tar xvf $CWD/src/$QT_TAR || exit 1
cd qt* || exit 1
CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure -prefix $INSTALL_PATH $QT_CONF || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/qt || exit 1
cp README LICENSE.LGPL LGPL_EXCEPTION.txt $INSTALL_PATH/docs/qt/ || exit 1

if [ "$1" == "qt" ]; then
  echo "Stopped after $1"
  exit 0
fi

# Install natron
cd $TMP_PATH || exit 1
tar xvf $CWD/src/$NATRON_TAR || exit 1
cd Natron* || exit 1
#patch -p0< $CWD/stylefix.diff || exit 1
cat $CWD/config.pri > config.pri || exit 1
mkdir build || exit 1
cd build || exit 1
$INSTALL_PATH/bin/qmake -r ../Project.pro || exit 1
make -j${MKJOBS} || exit 1
cp App/Natron $INSTALL_PATH/bin/ || exit 1
cp Renderer/NatronRenderer $INSTALL_PATH/bin/ || exit 1
cp -a ../Gui/Resources/OpenColorIO-Configs $INSTALL_PATH/share/ || exit 1
mkdir -p $INSTALL_PATH/docs/natron || exit 1
cp ../LICENSE.txt ../README* ../BUGS* ../CONTRI* ../Documentation/* $INSTALL_PATH/docs/natron/ || exit 1
mkdir -p $INSTALL_PATH/share/pixmaps || exit 1
cp ../Gui/Resources/Images/natronIcon256_linux.png $INSTALL_PATH/share/pixmaps/ || exit 1

# Create release
mkdir -p $CWD/Natron-$VERSION-$RELEASE-linux64/{bin,lib} $CWD/Natron-$VERSION-$RELEASE-linux64/share/{pixmaps,applications} || exit 1
cd $CWD/Natron-$VERSION-$RELEASE-linux64 || exit 1

cp $INSTALL_PATH/bin/{Natron*,ffmpeg} bin/ || exit 1
cp -a $INSTALL_PATH/Plugins . || exit 1
cp -a $INSTALL_PATH/share/OpenColorIO-Configs share/ || exit 1

if [ "$1" == "qt4" ];then
  cp -a $INSTALL_PATH/plugins/{imageformats,graphicssystems} bin/ || exit 1
else
  cp -a $INSTALL_PATH/plugins/{imageformats,platforms,generic} bin/ || exit 1
fi

cp -a $INSTALL_PATH/docs . || exit 1

CORE_DEPENDS=$(ldd bin/*|grep opt | awk '{print $3}')
for i in $CORE_DEPENDS; do
  cp -v $i lib/ || exit 1
done

OFX_DEPENDS=$(ldd Plugins/*/Contents/Linux-x86-64/*|grep opt | awk '{print $3}')
for x in $OFX_DEPENDS; do
  cp -v $x lib/ || exit 1
done

LIB_DEPENDS=$(ldd lib/*|grep opt | awk '{print $3}')
for y in $LIB_DEPENDS; do
  cp -v $y lib/ || exit 1
done

cat $CWD/Natron.sh > Natron || exit 1
cat $CWD/NatronRenderer.sh > NatronRenderer || exit 1
cat $CWD/Install.sh > Install.sh || exit 1
cat $CWD/Uninstall.sh > Uninstall.sh || exit 1
chmod +x Natron NatronRenderer Install.sh Uninstall.sh || exit 1

cp $INSTALL_PATH/share/pixmaps/natronIcon256_linux.png share/pixmaps/ || exit 1
cp $CWD/natron.desktop share/applications/ || exit 1

PLUG_DEPENDS=$(ldd bin/*/*|grep opt | awk '{print $3}')
for z in $PLUG_DEPENDS; do
  cp -v $z lib/ || exit 1
done

tar xvf $CWD/compat.tgz -C lib/ || exit 1
cat $CWD/README.txt > README.txt || exit 1

strip -s bin/*/*
strip -s bin/*
strip -s lib/*
strip -s Plugins/*/Contents/Linux-x86-64/*
chown root:root -R *

cd .. || exit 1
tar cvvzf Natron-$VERSION-$RELEASE-linux64.tgz Natron-$VERSION-$RELEASE-linux64 || exit 1
sha1sum Natron-$VERSION-$RELEASE-linux64.tgz > Natron-$VERSION-$RELEASE-linux64.tgz.sha1 || exit 1
cat $CWD/README.txt > Natron-$VERSION-$RELEASE-linux64.tgz.txt || exit 1
