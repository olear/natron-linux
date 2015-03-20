#!/bin/sh
#
# Build Natron SDK for Linux
# Written by Ole-André Rodlie <olear@fxarena.net>
#

gcc -v
sleep 5

# Dist files
SRC_URL=http://snapshots.natronvfx.com/source
QT4_TAR=qt-everywhere-opensource-src-4.8.6.tar.gz
QIFW_TAR=installer-framework-installer-framework-f586369bd5b0a876a148c203b0243a8378b45482.tar.gz
YASM_TAR=yasm-1.2.0.tar.gz
CMAKE_TAR=cmake-2.8.12.2.tar.gz
PY_TAR=Python-2.7.9.tar.xz
JPG_TAR=jpegsrc.v9a.tar.gz
OJPG_TAR=openjpeg-1.5.1.tar.gz
PNG_TAR=libpng-1.2.52.tar.xz
TIF_TAR=tiff-4.0.3.tar.gz
ILM_TAR=ilmbase-2.1.0.tar.gz
EXR_TAR=openexr-2.1.0.tar.gz
GLEW_TAR=glew-1.5.5.tgz
BOOST_TAR=boost_1_57_0.tar.bz2
CAIRO_TAR=cairo-1.12.16.tar.xz
FFMPEG_TAR=ffmpeg-2.2.14.tar.bz2
OCIO_TAR=OpenColorIO-1.0.9.tar.gz
OIIO_TAR=oiio-Release-1.4.16.tar.gz
PYSIDE_TAR=pyside-qt4.8+1.2.2.tar.bz2 
PY3_TAR=Python-3.4.3.tar.xz   
SHIBOK_TAR=shiboken-1.2.2.tar.bz2  
PYSIDETOOLS_TAR=Tools-0.2.15.tar.gz 
LIBXML_TAR=libxml2-2.9.2.tar.gz
LIBXSL_TAR=libxslt-1.1.28.tar.gz
FUSION_TAR=fusion-qt4-4531c2274371.tar.gz
SEE_TAR=SeExpr-db9610a24401fa7198c54c8768d0484175f54172.tar.gz

# SDK version
VERSION=2.0

# Arch
if [ -z "$ARCH" ]; then
  case "$( uname -m )" in
    i?86) export ARCH=i686 ;;
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
SDK=Linux-$ARCH-SDK

# Threads
if [ -z "$MKJOBS" ]; then
  MKJOBS=4
fi

# Setup
CWD=$(pwd)
INSTALL_PATH=/opt/Natron-$VERSION
TMP_PATH=$CWD/tmp

if [ -z "$REBUILD" ]; then
  if [ -d $INSTALL_PATH ]; then
    rm -rf $INSTALL_PATH || exit 1
  fi
  mkdir -p $INSTALL_PATH || exit 1
  mkdir -p $INSTALL_PATH/lib
  (cd $INSTALL_PATH; ln -sf lib lib64)
fi
if [ -d $TMP_PATH ]; then
  rm -rf $TMP_PATH || exit 1
fi
mkdir -p $TMP_PATH || exit 1
if [ ! -d $CWD/src ]; then
  mkdir -p $CWD/src || exit 1
fi

# Install yasm (needed by ffmpeg)
if [ ! -f /usr/local/bin/yasm ]; then
  cd $TMP_PATH || exit 1
  if [ ! -f $CWD/src/$YASM_TAR ]; then
    wget $SRC_URL/$YASM_TAR -O $CWD/src/$YASM_TAR || exit 1
  fi
  tar xvf $CWD/src/$YASM_TAR || exit 1
  cd yasm* || exit 1
  CFLAGS="$BF" CXXFLAGS="$BF" ./configure --prefix=/usr/local || exit 1
  make -j${MKJOBS} || exit 1
  make install || exit 1
fi

# Install cmake (needed by openjpeg and oico/oiio ++++)
if [ ! -f /usr/local/bin/cmake ]; then
  cd $TMP_PATH || exit 1
  if [ ! -f $CWD/src/$CMAKE_TAR ]; then
    wget $SRC_URL/$CMAKE_TAR -O $CWD/src/$CMAKE_TAR || exit 1
  fi
  tar xvf $CWD/src/$CMAKE_TAR || exit 1
  cd cmake* || exit 1
  CFLAGS="$BF" CXXFLAGS="$BF" ./configure --prefix=/usr/local || exit 1
  make -j${MKJOBS} || exit 1
  make install || exit 1
fi

# Install Python
cd $TMP_PATH || exit 1
if [ ! -f $CWD/src/$PY_TAR ]; then
  wget $SRC_URL/$PY_TAR -O $CWD/src/$PY_TAR || exit 1
fi
tar xvf $CWD/src/$PY_TAR || exit 1
cd Python* || exit 1
CFLAGS="$BF" CXXFLAGS="$BF" ./configure --prefix=$INSTALL_PATH --enable-shared || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/python || exit 1
cp LICENSE $INSTALL_PATH/docs/python/ || exit 1

cd $TMP_PATH || exit 1
if [ ! -f $CWD/src/$PY3_TAR ]; then
  wget $SRC_URL/$PY3_TAR -O $CWD/src/$PY3_TAR || exit 1
fi
tar xvf $CWD/src/$PY3_TAR || exit 1
cd Python-3* || exit 1
CFLAGS="$BF" CXXFLAGS="$BF" ./configure --prefix=$INSTALL_PATH --enable-shared || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/python3 || exit 1
cp LICENSE $INSTALL_PATH/docs/python3/ || exit 1

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
export PYTHON_INCLUDE=$INSTALL_PATH/include/python2.7

# Install libxml
cd $TMP_PATH || exit 1
if [ ! -f $CWD/src/$LIBXML_TAR ]; then
  wget $SRC_URL/$LIBXML_TAR -O $CWD/src/$LIBXML_TAR || exit 1
fi
tar xvf $CWD/src/$LIBXML_TAR || exit 1
cd libxml2* || exit 1
LDFLAGS="-L${INSTALL_PATH}/lib" CFLAGS="$BF" CXXFLAGS="$BF" ./configure --prefix=$INSTALL_PATH --with-threads --with-python=$INSTALL_PATH/bin/python2.7 --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/libxml || exit 1
cp COPY* Copy* $INSTALL_PATH/docs/libxml/

# Install libxsl
cd $TMP_PATH || exit 1
if [ ! -f $CWD/src/$LIBXSL_TAR ]; then
  wget $SRC_URL/$LIBXSL_TAR -O $CWD/src/$LIBXSL_TAR || exit 1
fi
tar xvf $CWD/src/$LIBXSL_TAR || exit 1
cd libxsl* || exit 1
LDFLAGS="-L${INSTALL_PATH}/lib" CFLAGS="$BF" CXXFLAGS="$BF" ./configure --prefix=$INSTALL_PATH --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/libxslt || exit 1
cp COPY* Copy* $INSTALL_PATH/docs/libxlt/ 

# Install boost
cd $TMP_PATH || exit 1
if [ ! -f $CWD/src/$BOOST_TAR ]; then
  wget $SRC_URL/$BOOST_TAR -O $CWD/src/$BOOST_TAR || exit 1
fi
tar xvf $CWD/src/$BOOST_TAR || exit 1
cd boost* || exit 1
CFLAGS="$BF" CXXFLAGS="$BF" ./bootstrap.sh || exit 1
CFLAGS="$BF" CXXFLAGS="$BF" ./b2 -j${MKJOBS} --disable-icu || exit 1
./b2 install --prefix=$INSTALL_PATH || exit 1
mkdir -p $INSTALL_PATH/docs/boost || exit 1
cp LICENSE_1_0.txt $INSTALL_PATH/docs/boost/ || exit 1

# Install jpeg
cd $TMP_PATH || exit 1
if [ ! -f $CWD/src/$JPG_TAR ]; then
  wget $SRC_URL/$JPG_TAR -O $CWD/src/$JPG_TAR || exit 1
fi
tar xvf $CWD/src/$JPG_TAR || exit 1
cd jpeg* || exit 1
CFLAGS="$BF" CXXFLAGS="$BF" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/jpeg || exit 1
cp LIC* COP* READ* AUTH* CONT* $INSTALL_PATH/docs/jpeg/

# Install png
cd $TMP_PATH || exit 1
if [ ! -f $CWD/src/$PNG_TAR ]; then
  wget $SRC_URL/$PNG_TAR -O $CWD/src/$PNG_TAR || exit 1
fi
tar xvf $CWD/src/$PNG_TAR || exit 1
cd libpng* || exit 1
CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/png || exit 1
cp LIC* COP* README AUTH* CONT* $INSTALL_PATH/docs/png/

# Install tiff
cd $TMP_PATH || exit 1
if [ ! -f $CWD/src/$TIF_TAR ]; then
  wget $SRC_URL/$TIF_TAR -O $CWD/src/$TIF_TAR || exit 1
fi
tar xvf $CWD/src/$TIF_TAR || exit 1
cd tiff* || exit 1
CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/tiff || exit 1
cp LIC* COP* README AUTH* CONT* $INSTALL_PATH/docs/tiff/

# Install openjpeg
cd $TMP_PATH || exit 1
if [ ! -f $CWD/src/$OJPG_TAR ]; then
  wget $SRC_URL/$OJPG_TAR -O $CWD/src/$OJPG_TAR || exit 1
fi
tar xvf $CWD/src/$OJPG_TAR || exit 1
cd openjpeg* || exit 1
./bootstrap.sh || exit 1
CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/openjpeg || exit 1
cp LIC* COP* READ* AUTH* CONT* $INSTALL_PATH/docs/openjpeg/

# Install openexr
cd $TMP_PATH || exit 1
if [ ! -f $CWD/src/$ILM_TAR ]; then
  wget $SRC_URL/$ILM_TAR -O $CWD/src/$ILM_TAR || exit 1
fi
tar xvf $CWD/src/$ILM_TAR || exit 1
cd ilmbase* || exit 1
CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/openexr || exit 1
cp LIC* COP* README AUTH* CONT* $INSTALL_PATH/docs/openexr/

cd $TMP_PATH || exit 1
if [ ! -f $CWD/src/$EXR_TAR ]; then
  wget $SRC_URL/$EXR_TAR -O $CWD/src/$EXR_TAR || exit 1
fi
tar xvf $CWD/src/$EXR_TAR || exit 1
cd openexr* || exit 1
CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
cp LIC* COP* README AUTH* CONT* $INSTALL_PATH/docs/openexr/

# Install glew
cd $TMP_PATH || exit 1
if [ ! -f $CWD/src/$GLEW_TAR ]; then
  wget $SRC_URL/$GLEW_TAR -O $CWD/src/$GLEW_TAR || exit 1
fi
tar xvf $CWD/src/$GLEW_TAR || exit 1
cd glew* || exit 1
patch -p1< $CWD/patches/glew-1.5.2-add-needed.patch || exit 1
patch -p1< $CWD/patches/glew-1.5.2-makefile.patch || exit 1
sed -i -e 's/\r//g' config/config.guess || exit 1
if [ "$ARCH" == "i686" ]; then
make -j${MKJOBS} 'CFLAGS.EXTRA=-O2 -g -march=i686 -mtune=i686' includedir=/usr/include GLEW_DEST= libdir=/usr/lib bindir=/usr/bin || exit 1
else
make -j${MKJOBS} 'CFLAGS.EXTRA=-O2 -g -m64 -fPIC -mtune=generic' includedir=/usr/include GLEW_DEST= libdir=/usr/lib64 bindir=/usr/bin || exit 1
fi
make install GLEW_DEST=$INSTALL_PATH libdir=/lib bindir=/bin includedir=/include || exit 1
mkdir -p $INSTALL_PATH/docs/glew || exit 1
cp LICENSE.txt README.txt $INSTALL_PATH/docs/glew/ || exit 1

# Install cairo
cd $TMP_PATH || exit 1
if [ ! -f $CWD/src/$CAIRO_TAR ]; then
  wget $SRC_URL/$CAIRO_TAR -O $CWD/src/$CAIRO_TAR || exit 1
fi
tar xvf $CWD/src/$CAIRO_TAR || exit 1
cd cairo* || exit 1
CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/cairo || exit 1
cp COPYING* README AUTHORS $INSTALL_PATH/docs/cairo/ || exit 1

# Install ffmpeg
cd $TMP_PATH || exit 1
if [ ! -f $CWD/src/$FFMPEG_TAR ]; then
  wget $SRC_URL/$FFMPEG_TAR -O $CWD/src/$FFMPEG_TAR || exit 1
fi
tar xvf $CWD/src/$FFMPEG_TAR || exit 1
cd ffmpeg* || exit 1
CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/ffmpeg || exit 1
cp LICENSE COPYING.LGPLv2.1 README MAINTAINERS CREDITS $INSTALL_PATH/docs/ffmpeg/ || exit 1

# Install ocio
cd $TMP_PATH || exit 1
if [ ! -f $CWD/src/$OCIO_TAR ]; then
  wget $SRC_URL/$OCIO_TAR -O $CWD/src/$OCIO_TAR || exit 1
fi
tar xvf $CWD/src/$OCIO_TAR || exit 1
cd OpenColorIO* || exit 1
mkdir build || exit 1
cd build || exit 1
# -DUSE_EXTERNAL_LCMS=OFF
#CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" cmake .. -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH -DCMAKE_BUILD_TYPE=Release -DOCIO_BUILD_JNIGLUE=OFF -DOCIO_BUILD_NUKE=OFF -DOCIO_BUILD_SHARED=ON -DOCIO_BUILD_STATIC=OFF -DOCIO_STATIC_JNIGLUE=OFF -DUSE_EXTERNAL_LCMS=ON -DOCIO_BUILD_TRUELIGHT=OFF -DUSE_EXTERNAL_TINYXML=OFF -DUSE_EXTERNAL_YAML=OFF -DOCIO_BUILD_APPS=OFF -DOCIO_USE_BOOST_PTR=ON -DOCIO_BUILD_TESTS=OFF -DOCIO_BUILD_PYGLUE=OFF
CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" cmake .. -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH -DCMAKE_BUILD_TYPE=Release -DOCIO_BUILD_SHARED=ON -DOCIO_BUILD_STATIC=OFF || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/ocio || exit 1
cp ../LICENSE ../README $INSTALL_PATH/docs/ocio/ || exit 1

# Install oiio
cd $TMP_PATH || exit 1
if [ ! -f $CWD/src/$OIIO_TAR ]; then
  wget $SRC_URL/$OIIO_TAR -O $CWD/src/$OIIO_TAR || exit 1
fi
tar xvf $CWD/src/$OIIO_TAR || exit 1
cd oiio* || exit 1
patch -p0< $CWD/patches/stupid_cmake.diff || exit 1
patch -p0< $CWD/patches/stupid_cmake_again.diff || exit 1
mkdir build || exit 1
cd build || exit 1
CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" CXXFLAGS="-fPIC" cmake USE_OPENSSL=0 OPENEXR_HOME=$INSTALL_PATH OPENJPEG_HOME=$INSTALL_PATH OPENJPEG_INCLUDE_DIR=$INSTALL_PATH/include/openjpeg-1.5 THIRD_PARTY_TOOLS_HOME=$INSTALL_PATH USE_QT=0 USE_TBB=0 USE_PYTHON=0 USE_FIELD3D=0 USE_OPENJPEG=1 USE_OCIO=1 OIIO_BUILD_TESTS=0 OIIO_BUILD_TOOLS=0 OCIO_HOME=$INSTALL_PATH -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH .. || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/oiio || exit 1
cp ../LICENSE ../README* ../CREDITS $INSTALL_PATH/docs/oiio || exit 1

# Qt
cd $TMP_PATH || exit 1
if [ "$1" == "qt5" ]; then
QT_TAR=$QT5_TAR
QT_CONF="-no-openssl -opengl desktop -opensource -nomake examples -nomake tests -release -no-gtkstyle -confirm-license -no-c++11 -I${INSTALL_PATH}/include -L${INSTALL_PATH}/lib"
else
QT_TAR=$QT4_TAR
QT_CONF="-no-multimedia -no-openssl -confirm-license -release -opensource -opengl desktop -nomake demos -nomake docs -nomake examples -no-gtkstyle -no-webkit -I${INSTALL_PATH}/include -L${INSTALL_PATH}/lib"
fi

if [ ! -f $CWD/src/$QT_TAR ]; then
  wget $SRC_URL/$QT_TAR -O $CWD/src/$QT_TAR || exit 1
fi
tar xvf $CWD/src/$QT_TAR || exit 1
cd qt* || exit 1
if [ "$1" == "qt5" ]; then
  patch -p0< $CWD/patches/no-egl.diff || exit 1
fi
CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure -prefix $INSTALL_PATH $QT_CONF -shared || exit 1

# https://bugreports.qt-project.org/browse/QTBUG-5385
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(pwd)/lib make -j${MKJOBS} || exit 
1

make install || exit 1
mkdir -p $INSTALL_PATH/docs/qt || exit 1
cp README LICENSE.LGPL LGPL_EXCEPTION.txt $INSTALL_PATH/docs/qt/ || exit 1
rm -rf $TMP_PATH/qt*

# QTIFW
cd $TMP_PATH || exit 1
QTIFW_CONF="-no-multimedia -no-gif -qt-libpng -no-opengl -no-libmng -no-libtiff -no-libjpeg -static -no-openssl -confirm-license -release -opensource -nomake demos -nomake docs -nomake examples -no-gtkstyle -no-webkit -I${INSTALL_PATH}/include -L${INSTALL_PATH}/lib"

tar xvf $CWD/src/$QT4_TAR || exit 1
cd qt*4.8* || exit 1
CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure -prefix $TMP_PATH/qt4 $QTIFW_CONF || exit 1

# https://bugreports.qt-project.org/browse/QTBUG-5385
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(pwd)/lib make -j${MKJOBS} || exit 
1

make install || exit 1
cd ..
if [ ! -f $CWD/src/$QIFW_TAR ]; then
  wget $SRC_URL/$QIFW_TAR -O $CWD/src/$QIFW_TAR || exit 1
fi
tar xvf $CWD/src/$QIFW_TAR || exit 1
cd installer* || exit 1
$TMP_PATH/qt4/bin/qmake || exit 1
make -j${MKJOBS} || exit 1
strip -s bin/*
cp bin/* $INSTALL_PATH/bin/ || exit 1
rm -rf $TMP_PATH/qt4

# Force py3
export PYTHON_PATH=$INSTALL_PATH/lib/python3.4
export PYTHON_INCLUDE=$INSTALL_PATH/include/python3.4

# Install shiboken
cd $TMP_PATH || exit 1
if [ ! -f $CWD/src/$SHIBOK_TAR ]; then
  wget $SRC_URL/$SHIBOK_TAR -O $CWD/src/$SHIBOK_TAR || exit 1
fi
tar xvf $CWD/src/$SHIBOK_TAR || exit 1
cd shiboken* || exit 1
mkdir -p build && cd build || exit 1
cmake ../ -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH  \
  -DCMAKE_BUILD_TYPE=Release   \
  -DBUILD_TESTS=OFF            \
  -DPYTHON_EXECUTABLE=$INSTALL_PATH/bin/python3 \
  -DPYTHON_LIBRARY=$INSTALL_PATH/lib/libpython3.4.so \
  -DPYTHON_INCLUDE_DIR=$INSTALL_PATH/include/python3.4 \
  -DUSE_PYTHON3=yes \
  -DQT_QMAKE_EXECUTABLE=$INSTALL_PATH/bin/qmake
make -j${MKJOBS} || exit 1 
make install || exit 1
mkdir -p $INSTALL_PATH/docs/shibroken || exit 1
cp ../COPY* $INSTALL_PATH/docs/shibroken/

# Install pyside
cd $TMP_PATH || exit 1
if [ ! -f $CWD/src/$PYSIDE_TAR ]; then
  wget $SRC_URL/$PYSIDE_TAR -O $CWD/src/$PYSIDE_TAR || exit 1
fi
tar xvf $CWD/src/$PYSIDE_TAR || exit 1
cd pyside* || exit 1
mkdir -p build && cd build || exit 1
cmake .. -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTS=OFF \
  -DQT_QMAKE_EXECUTABLE=$INSTALL_PATH/bin/qmake \
  -DPYTHON_EXECUTABLE=$INSTALL_PATH/bin/python3 \
  -DPYTHON_LIBRARY=$INSTALL_PATH/lib/libpython3.4.so \
  -DPYTHON_INCLUDE_DIR=$INSTALL_PATH/include/python3.4
make -j${MKJOBS} || exit 1 
make install || exit 1
mkdir -p $INSTALL_PATH/docs/pyside || exit 1
cp ../COPY* $INSTALL_PATH/docs/pyside/ || exit 1

# Install SeExpr
cd $TMP_PATH || exit 1
if [ ! -f $CWD/src/$SEE_TAR ]; then
  wget $SRC_URL/$SEE_TAR -O $CWD/src/$SEE_TAR || exit 1
fi
tar xvf $CWD/src/$SEE_TAR || exit 1
cd SeExpr* || exit 1
patch -p0< $CWD/patches/seexpr.diff || exit 1
patch -p0< $CWD/patches/seexpr2.diff || exit 1
mkdir build || exit 1
cd build || exit 1
CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" cmake .. -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH || exit 1
make || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/seexpr || exit 1
cp ../LIC* ../COP* ../README* ../AUTH* ../CONT* $INSTALL_PATH/docs/seexpr/
echo $SEE_GIT_VERSION > $INSTALL_PATH/docs/seexpr/VERSION || exit 1


# Install qtfusion
#cd $TMP_PATH || exit 1
#if [ ! -f $CWD/src/$FUSION_TAR ]; then
#  wget $SRC_URL/$FUSION_TAR -O $CWD/src/$FUSION_TAR || exit 1
#fi
#tar xvf $CWD/src/$FUSION_TAR || exit 1
#cd fusion* || exit 1


# SDK DONE
cd $INSTALL_PATH/.. || exit 1
tar cvvJf $CWD/src/Natron-$VERSION-$SDK.tar.xz Natron-$VERSION || exit 1

echo "Natron SDK Done!"
echo "Use $CWD/src/Natron-$VERSION-$SDK.tar.xz for future builds, only rebuild on bugs or security issues."
echo
