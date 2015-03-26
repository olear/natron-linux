#!/bin/sh
#
# Build Natron SDK for Linux
# Written by Ole-André Rodlie <olear@fxarena.net>
#

source $(pwd)/common.sh || exit 1
SDK=Linux-$ARCH-SDK
echo
echo "Building Natron-$SDK_VERSION-$SDK using GCC 4.$GCC_V with $MKJOBS threads ..."
echo
sleep 2

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
if [ ! -d $SRC_PATH ]; then
  mkdir -p $SRC_PATH || exit 1
fi

# Install yasm
if [ ! -f /usr/local/bin/yasm ]; then
  cd $TMP_PATH || exit 1
  if [ ! -f $SRC_PATH/$YASM_TAR ]; then
    wget $SRC_URL/$YASM_TAR -O $SRC_PATH/$YASM_TAR || exit 1
  fi
  tar xvf $SRC_PATH/$YASM_TAR || exit 1
  cd yasm* || exit 1
  CFLAGS="$BF" CXXFLAGS="$BF" ./configure --prefix=/usr/local || exit 1
  make -j${MKJOBS} || exit 1
  make install || exit 1
fi

# Install cmake
if [ ! -f /usr/local/bin/cmake ]; then
  cd $TMP_PATH || exit 1
  if [ ! -f $SRC_PATH/$CMAKE_TAR ]; then
    wget $SRC_URL/$CMAKE_TAR -O $SRC_PATH/$CMAKE_TAR || exit 1
  fi
  tar xvf $SRC_PATH/$CMAKE_TAR || exit 1
  cd cmake* || exit 1
  CFLAGS="$BF" CXXFLAGS="$BF" ./configure --prefix=/usr/local || exit 1
  make -j${MKJOBS} || exit 1
  make install || exit 1
fi

# Install Python2
cd $TMP_PATH || exit 1
if [ ! -f $SRC_PATH/$PY_TAR ]; then
  wget $SRC_URL/$PY_TAR -O $SRC_PATH/$PY_TAR || exit 1
fi
tar xvf $SRC_PATH/$PY_TAR || exit 1
cd Python* || exit 1
CFLAGS="$BF" CXXFLAGS="$BF" ./configure --prefix=$INSTALL_PATH --enable-shared || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1

# Install Python3
cd $TMP_PATH || exit 1
if [ ! -f $SRC_PATH/$PY3_TAR ]; then
  wget $SRC_URL/$PY3_TAR -O $SRC_PATH/$PY3_TAR || exit 1
fi
tar xvf $SRC_PATH/$PY3_TAR || exit 1
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
if [ ! -f $SRC_PATH/$LIBXML_TAR ]; then
  wget $SRC_URL/$LIBXML_TAR -O $SRC_PATH/$LIBXML_TAR || exit 1
fi
tar xvf $SRC_PATH/$LIBXML_TAR || exit 1
cd libxml2* || exit 1
LDFLAGS="-L${INSTALL_PATH}/lib" CFLAGS="$BF" CXXFLAGS="$BF" ./configure --prefix=$INSTALL_PATH --with-threads --with-python=$INSTALL_PATH/bin/python2.7 --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1

# Install libxsl
cd $TMP_PATH || exit 1
if [ ! -f $SRC_PATH/$LIBXSL_TAR ]; then
  wget $SRC_URL/$LIBXSL_TAR -O $SRC_PATH/$LIBXSL_TAR || exit 1
fi
tar xvf $SRC_PATH/$LIBXSL_TAR || exit 1
cd libxsl* || exit 1
LDFLAGS="-L${INSTALL_PATH}/lib" CFLAGS="$BF" CXXFLAGS="$BF" ./configure --prefix=$INSTALL_PATH --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1

# Install boost
cd $TMP_PATH || exit 1
if [ ! -f $SRC_PATH/$BOOST_TAR ]; then
  wget $SRC_URL/$BOOST_TAR -O $SRC_PATH/$BOOST_TAR || exit 1
fi
tar xvf $SRC_PATH/$BOOST_TAR || exit 1
cd boost* || exit 1
CFLAGS="$BF" CXXFLAGS="$BF" ./bootstrap.sh || exit 1
CFLAGS="$BF" CXXFLAGS="$BF" ./b2 -j${MKJOBS} --disable-icu || exit 1
./b2 install --prefix=$INSTALL_PATH || exit 1
mkdir -p $INSTALL_PATH/docs/boost || exit 1
cp LICENSE_1_0.txt $INSTALL_PATH/docs/boost/ || exit 1

# Install jpeg
cd $TMP_PATH || exit 1
if [ ! -f $SRC_PATH/$JPG_TAR ]; then
  wget $SRC_URL/$JPG_TAR -O $SRC_PATH/$JPG_TAR || exit 1
fi
tar xvf $SRC_PATH/$JPG_TAR || exit 1
cd jpeg* || exit 1
CFLAGS="$BF" CXXFLAGS="$BF" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/jpeg || exit 1
cp LIC* COP* READ* AUTH* CONT* $INSTALL_PATH/docs/jpeg/

# Install png
cd $TMP_PATH || exit 1
if [ ! -f $SRC_PATH/$PNG_TAR ]; then
  wget $SRC_URL/$PNG_TAR -O $SRC_PATH/$PNG_TAR || exit 1
fi
tar xvf $SRC_PATH/$PNG_TAR || exit 1
cd libpng* || exit 1
CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/png || exit 1
cp LIC* COP* README AUTH* CONT* $INSTALL_PATH/docs/png/

# Install tiff
cd $TMP_PATH || exit 1
if [ ! -f $SRC_PATH/$TIF_TAR ]; then
  wget $SRC_URL/$TIF_TAR -O $SRC_PATH/$TIF_TAR || exit 1
fi
tar xvf $SRC_PATH/$TIF_TAR || exit 1
cd tiff* || exit 1
CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/tiff || exit 1
cp LIC* COP* README AUTH* CONT* $INSTALL_PATH/docs/tiff/

# Install jasper
cd $TMP_PATH || exit 1
if [ ! -f $SRC_PATH/$JASP_TAR ]; then
  wget $SRC_URL/$JASP_TAR -O $SRC_PATH/$JASP_TAR || exit 1
fi
unzip $SRC_PATH/$JASP_TAR || exit 1
cd jasper* || exit 1
CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/jasper || exit 1
cp LIC* COP* Copy* README AUTH* CONT* $INSTALL_PATH/docs/jasper/

# Install lcms
cd $TMP_PATH || exit 1
if [ ! -f $SRC_PATH/$LCMS_TAR ]; then
wget $SRC_URL/$LCMS_TAR -O $SRC_PATH/$LCMS_TAR || exit 1
fi
tar xvf $SRC_PATH/$LCMS_TAR || exit 1
cd lcms* || exit 1
CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/lcms || exit 1
cp LIC* COP* README AUTH* CONT* $INSTALL_PATH/docs/lcms/

# Install openjpeg
cd $TMP_PATH || exit 1
if [ ! -f $SRC_PATH/$OJPG_TAR ]; then
  wget $SRC_URL/$OJPG_TAR -O $SRC_PATH/$OJPG_TAR || exit 1
fi
tar xvf $SRC_PATH/$OJPG_TAR || exit 1
cd openjpeg* || exit 1
./bootstrap.sh || exit 1
CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/openjpeg || exit 1
cp LIC* COP* READ* AUTH* CONT* $INSTALL_PATH/docs/openjpeg/

# Install libraw
cd $TMP_PATH || exit 1
if [ ! -f $SRC_PATH/$LIBRAW_TAR ]; then
 wget $SRC_URL/$LIBRAW_TAR -O $SRC_PATH/$LIBRAW_TAR || exit 1
fi
tar xvf $SRC_PATH/$LIBRAW_TAR || exit 1
cd LibRaw* || exit 1
mkdir build && cd build
CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" cmake .. -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH -DCMAKE_BUILD_TYPE=Release || exit 1
make -j${MKJOBS} || exit 1
make install
mkdir -p $INSTALL_PATH/docs/libraw || exit 1
cp ../README ../COPYRIGHT ../LIC* $INSTALL_PATH/docs/libraw/ || exit 1

# Install openexr
cd $TMP_PATH || exit 1
if [ ! -f $SRC_PATH/$ILM_TAR ]; then
  wget $SRC_URL/$ILM_TAR -O $SRC_PATH/$ILM_TAR || exit 1
fi
tar xvf $SRC_PATH/$ILM_TAR || exit 1
cd ilmbase* || exit 1
CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/openexr || exit 1
cp LIC* COP* README AUTH* CONT* $INSTALL_PATH/docs/openexr/

cd $TMP_PATH || exit 1
if [ ! -f $SRC_PATH/$EXR_TAR ]; then
  wget $SRC_URL/$EXR_TAR -O $SRC_PATH/$EXR_TAR || exit 1
fi
tar xvf $SRC_PATH/$EXR_TAR || exit 1
cd openexr* || exit 1
CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
cp LIC* COP* README AUTH* CONT* $INSTALL_PATH/docs/openexr/

# Install glew
cd $TMP_PATH || exit 1
if [ ! -f $SRC_PATH/$GLEW_TAR ]; then
  wget $SRC_URL/$GLEW_TAR -O $SRC_PATH/$GLEW_TAR || exit 1
fi
tar xvf $SRC_PATH/$GLEW_TAR || exit 1
cd glew* || exit 1
if [ "$ARCH" == "i686" ]; then
make -j${MKJOBS} 'CFLAGS.EXTRA=-O2 -g -march=i686 -mtune=i686' includedir=/usr/include GLEW_DEST= libdir=/usr/lib bindir=/usr/bin || exit 1
else
make -j${MKJOBS} 'CFLAGS.EXTRA=-O2 -g -m64 -fPIC -mtune=generic' includedir=/usr/include GLEW_DEST= libdir=/usr/lib64 bindir=/usr/bin || exit 1
fi
make install GLEW_DEST=$INSTALL_PATH libdir=/lib bindir=/bin includedir=/include || exit 1
mkdir -p $INSTALL_PATH/docs/glew || exit 1
cp LICENSE.txt README.txt $INSTALL_PATH/docs/glew/ || exit 1

# Install pixman
if [ ! -f $SRC_PATH/$PIX_TAR ]; then
  wget $SRC_URL/$PIX_TAR -O $SRC_PATH/$PIX_TAR || exit 1
fi
tar xvf $SRC_PATH/$PIX_TAR || exit 1
cd pixman* || exit 1
CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/pixman || exit 1
cp COPYING* README AUTHORS $INSTALL_PATH/docs/pixman/ || exit 1

# Install cairo
cd $TMP_PATH || exit 1
if [ ! -f $SRC_PATH/$CAIRO_TAR ]; then
  wget $SRC_URL/$CAIRO_TAR -O $SRC_PATH/$CAIRO_TAR || exit 1
fi
tar xvf $SRC_PATH/$CAIRO_TAR || exit 1
cd cairo* || exit 1
CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include -I${INSTALL_PATH}/include/pixman-1" LDFLAGS="-L${INSTALL_PATH}/lib -lpixman-1" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/cairo || exit 1
cp COPYING* README AUTHORS $INSTALL_PATH/docs/cairo/ || exit 1

# Install ffmpeg
cd $TMP_PATH || exit 1
if [ ! -f $SRC_PATH/$FFMPEG_TAR ]; then
  wget $SRC_URL/$FFMPEG_TAR -O $SRC_PATH/$FFMPEG_TAR || exit 1
fi
tar xvf $SRC_PATH/$FFMPEG_TAR || exit 1
cd ffmpeg* || exit 1
CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/ffmpeg || exit 1
cp COPYING.LGPLv2.1 CREDITS $INSTALL_PATH/docs/ffmpeg/ 

# Install ocio
cd $TMP_PATH || exit 1
if [ ! -f $SRC_PATH/$OCIO_TAR ]; then
  wget $SRC_URL/$OCIO_TAR -O $SRC_PATH/$OCIO_TAR || exit 1
fi
tar xvf $SRC_PATH/$OCIO_TAR || exit 1
cd OpenColorIO* || exit 1
mkdir build || exit 1
cd build || exit 1
#CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" cmake .. -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH -DCMAKE_BUILD_TYPE=Release -DOCIO_BUILD_JNIGLUE=OFF -DOCIO_BUILD_NUKE=OFF -DOCIO_BUILD_SHARED=ON -DOCIO_BUILD_STATIC=OFF -DOCIO_STATIC_JNIGLUE=OFF -DUSE_EXTERNAL_LCMS=ON -DOCIO_BUILD_TRUELIGHT=OFF -DUSE_EXTERNAL_TINYXML=OFF -DUSE_EXTERNAL_YAML=OFF -DOCIO_BUILD_APPS=OFF -DOCIO_USE_BOOST_PTR=ON -DOCIO_BUILD_TESTS=OFF -DOCIO_BUILD_PYGLUE=OFF
CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" cmake .. -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH -DCMAKE_BUILD_TYPE=Release -DOCIO_BUILD_SHARED=ON -DOCIO_BUILD_STATIC=OFF || exit 1
# dont work, wtf! #-DUSE_EXTERNAL_LCMS=ON || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/ocio || exit 1
cp ../LICENSE ../README $INSTALL_PATH/docs/ocio/ || exit 1

# Install oiio
cd $TMP_PATH || exit 1
if [ ! -f $SRC_PATH/$OIIO_TAR ]; then
  wget $SRC_URL/$OIIO_TAR -O $SRC_PATH/$OIIO_TAR || exit 1
fi
tar xvf $SRC_PATH/$OIIO_TAR || exit 1
cd oiio* || exit 1
patch -p0< $CWD/installer/patches/stupid_cmake.diff || exit 1
patch -p0< $CWD/installer/patches/stupid_cmake_again.diff || exit 1
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

if [ ! -f $SRC_PATH/$QT_TAR ]; then
  wget $SRC_URL/$QT_TAR -O $SRC_PATH/$QT_TAR || exit 1
fi
tar xvf $SRC_PATH/$QT_TAR || exit 1
cd qt* || exit 1
QT_SRC=$(pwd)/src
if [ "$1" == "qt5" ]; then
  patch -p0< $CWD/installer/patches/no-egl-in-qt5.diff || exit 1
fi
CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure -prefix $INSTALL_PATH $QT_CONF -shared || exit 1

# https://bugreports.qt-project.org/browse/QTBUG-5385
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(pwd)/lib make -j${MKJOBS} || exit 
1

make install || exit 1
mkdir -p $INSTALL_PATH/docs/qt || exit 1
cp README LICENSE.LGPL LGPL_EXCEPTION.txt $INSTALL_PATH/docs/qt/ || exit 1
rm -rf $TMP_PATH/qt*

# Force py3
export PYTHON_PATH=$INSTALL_PATH/lib/python3.4
export PYTHON_INCLUDE=$INSTALL_PATH/include/python3.4

# Install shiboken
cd $TMP_PATH || exit 1
if [ ! -f $SRC_PATH/$SHIBOK_TAR ]; then
  wget $SRC_URL/$SHIBOK_TAR -O $SRC_PATH/$SHIBOK_TAR || exit 1
fi
tar xvf $SRC_PATH/$SHIBOK_TAR || exit 1
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
if [ ! -f $SRC_PATH/$PYSIDE_TAR ]; then
  wget $SRC_URL/$PYSIDE_TAR -O $SRC_PATH/$PYSIDE_TAR || exit 1
fi
tar xvf $SRC_PATH/$PYSIDE_TAR || exit 1
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
if [ ! -f $SRC_PATH/$SEE_TAR ]; then
  wget $SRC_URL/$SEE_TAR -O $SRC_PATH/$SEE_TAR || exit 1
fi
tar xvf $SRC_PATH/$SEE_TAR || exit 1
cd SeExpr* || exit 1
mkdir build || exit 1
cd build || exit 1
CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" cmake .. -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH || exit 1
make || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/seexpr || exit 1
cp ../README ../src/doc/license.txt $INSTALL_PATH/docs/seexpr/ || exit 1

# Installer
if [ "$SSL_TAR" != "" ]; then
  cd $TMP_PATH || exit 1
  if [ ! -f $SRC_PATH/$SSL_TAR ]; then
    wget $SRC_URL/$SSL_TAR -O $SRC_PATH/$SSL_TAR || exit 1
  fi
  tar xvf $SRC_PATH/$SSL_TAR || exit 1
  cd openssl* || exit 1
  CFLAGS="$BF" CXXFLAGS="$BF" ./config --prefix=$INSTALL_PATH || exit 1
  make || exit 1
  make install || exit 1
fi

cd $TMP_PATH || exit 1
QTIFW_CONF="-no-multimedia -no-gif -qt-libpng -no-opengl -no-libmng -no-libtiff -no-libjpeg -static -no-openssl -confirm-license -release -opensource -nomake demos -nomake docs -nomake examples -no-gtkstyle -no-webkit -I${INSTALL_PATH}/include -L${INSTALL_PATH}/lib"

tar xvf $SRC_PATH/$QT4_TAR || exit 1
cd qt*4.8* || exit 1
CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure -prefix $TMP_PATH/qt4 $QTIFW_CONF || exit 1

# https://bugreports.qt-project.org/browse/QTBUG-5385
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(pwd)/lib make -j${MKJOBS} || exit
1

make install || exit 1
cd ..
if [ ! -f $SRC_PATH/$QIFW_TAR ]; then
  wget $SRC_URL/$QIFW_TAR -O $SRC_PATH/$QIFW_TAR || exit 1
fi
tar xvf $SRC_PATH/$QIFW_TAR || exit 1
cd installer* || exit 1
$TMP_PATH/qt4/bin/qmake || exit 1
make -j${MKJOBS} || exit 1
strip -s bin/*
cp bin/* $INSTALL_PATH/bin/ || exit 1
rm -rf $TMP_PATH/qt4

# Done, make a tarball
cd $INSTALL_PATH/.. || exit 1
tar cvvJf $SRC_PATH/Natron-$SDK_VERSION-$SDK.tar.xz Natron-$SDK_VERSION || exit 1

echo
echo "Natron SDK Done: $SRC_PATH/Natron-$SDK_VERSION-$SDK.tar.xz"
echo
exit 0

