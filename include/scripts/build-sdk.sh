#!/bin/sh
#
# Build Natron SDK for Linux
# Written by Ole-André Rodlie <olear@fxarena.net>
#

source $(pwd)/common.sh || exit 1
SDK=Linux-$ARCH-SDK

if [ -z "$MKJOBS" ]; then
    #Default to 4 threads
    MKJOBS=$DEFAULT_MKJOBS
fi

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
else
  echo "Rebuilding ..."
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
    wget $THIRD_PARTY_SRC_URL/$YASM_TAR -O $SRC_PATH/$YASM_TAR || exit 1
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
    wget $THIRD_PARTY_SRC_URL/$CMAKE_TAR -O $SRC_PATH/$CMAKE_TAR || exit 1
  fi
  tar xvf $SRC_PATH/$CMAKE_TAR || exit 1
  cd cmake* || exit 1
  CFLAGS="$BF" CXXFLAGS="$BF" ./configure --prefix=/usr/local || exit 1
  make -j${MKJOBS} || exit 1
  make install || exit 1
fi

# Install Python3
if [ ! -f $INSTALL_PATH/lib/pkgconfig/python3.pc ]; then
  cd $TMP_PATH || exit 1
  if [ ! -f $SRC_PATH/$PY3_TAR ]; then
    wget $THIRD_PARTY_SRC_URL/$PY3_TAR -O $SRC_PATH/$PY3_TAR || exit 1
  fi
  tar xvf $SRC_PATH/$PY3_TAR || exit 1
  cd Python-3* || exit 1
  CFLAGS="$BF" CXXFLAGS="$BF" ./configure --prefix=$INSTALL_PATH --enable-shared || exit 1
  make -j${MKJOBS} || exit 1
  make install || exit 1
  mkdir -p $INSTALL_PATH/docs/python3 || exit 1
  cp LICENSE $INSTALL_PATH/docs/python3/ || exit 1
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
export PYTHON_INCLUDE=$INSTALL_PATH/include/python2.7

# Install boost
if [ ! -f $INSTALL_PATH/lib/libboost_atomic.so ]; then
  cd $TMP_PATH || exit 1
  if [ ! -f $SRC_PATH/$BOOST_TAR ]; then
    wget $THIRD_PARTY_SRC_URL/$BOOST_TAR -O $SRC_PATH/$BOOST_TAR || exit 1
  fi
  tar xvf $SRC_PATH/$BOOST_TAR || exit 1
  cd boost_* || exit 1
  CFLAGS="$BF" CXXFLAGS="$BF" ./bootstrap.sh || exit 1
  CFLAGS="$BF" CXXFLAGS="$BF" ./b2 -j${MKJOBS} --disable-icu || exit 1
  ./b2 install --prefix=$INSTALL_PATH || exit 1
  mkdir -p $INSTALL_PATH/docs/boost || exit 1
  cp LICENSE_1_0.txt $INSTALL_PATH/docs/boost/ || exit 1
fi

# Install jpeg
if [ ! -f $INSTALL_PATH/lib/libjpeg.a ]; then
  cd $TMP_PATH || exit 1
  if [ ! -f $SRC_PATH/$JPG_TAR ]; then
    wget $THIRD_PARTY_SRC_URL/$JPG_TAR -O $SRC_PATH/$JPG_TAR || exit 1
  fi
  tar xvf $SRC_PATH/$JPG_TAR || exit 1
  cd jpeg-* || exit 1
  CFLAGS="$BF" CXXFLAGS="$BF" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --enable-static || exit 1
  make -j${MKJOBS} || exit 1
  make install || exit 1
  mkdir -p $INSTALL_PATH/docs/jpeg || exit 1
  cp LIC* COP* READ* AUTH* CONT* $INSTALL_PATH/docs/jpeg/
fi

# Install png
if [ ! -f $INSTALL_PATH/lib/pkgconfig/libpng.pc ]; then
  cd $TMP_PATH || exit 1
  if [ ! -f $SRC_PATH/$PNG_TAR ]; then
    wget $THIRD_PARTY_SRC_URL/$PNG_TAR -O $SRC_PATH/$PNG_TAR || exit 1
  fi
  tar xvf $SRC_PATH/$PNG_TAR || exit 1
  cd libpng* || exit 1
  CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --enable-static || exit 1
  make -j${MKJOBS} || exit 1
  make install || exit 1
  mkdir -p $INSTALL_PATH/docs/png || exit 1
  cp LIC* COP* README AUTH* CONT* $INSTALL_PATH/docs/png/
fi

# Install tiff
if [ ! -f $INSTALL_PATH/lib/pkgconfig/libtiff-4.pc ]; then
  cd $TMP_PATH || exit 1
  if [ ! -f $SRC_PATH/$TIF_TAR ]; then
    wget $THIRD_PARTY_SRC_URL/$TIF_TAR -O $SRC_PATH/$TIF_TAR || exit 1
  fi
  tar xvf $SRC_PATH/$TIF_TAR || exit 1
  cd tiff-* || exit 1
  CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --enable-static || exit 1
  make -j${MKJOBS} || exit 1
  make install || exit 1
  mkdir -p $INSTALL_PATH/docs/tiff || exit 1
  cp LIC* COP* README AUTH* CONT* $INSTALL_PATH/docs/tiff/
fi

# Install jasper
if [ ! -f $INSTALL_PATH/lib/libjasper.a ]; then
  cd $TMP_PATH || exit 1
  if [ ! -f $SRC_PATH/$JASP_TAR ]; then
    wget $THIRD_PARTY_SRC_URL/$JASP_TAR -O $SRC_PATH/$JASP_TAR || exit 1
  fi
  unzip $SRC_PATH/$JASP_TAR || exit 1
  cd jasper* || exit 1
  CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --enable-static || exit 1
  make -j${MKJOBS} || exit 1
  make install || exit 1
  mkdir -p $INSTALL_PATH/docs/jasper || exit 1
  cp LIC* COP* Copy* README AUTH* CONT* $INSTALL_PATH/docs/jasper/
fi

# Install lcms
if [ ! -f $INSTALL_PATH/lib/pkgconfig/lcms2.pc ]; then
  cd $TMP_PATH || exit 1
  if [ ! -f $SRC_PATH/$LCMS_TAR ]; then
    wget $THIRD_PARTY_SRC_URL/$LCMS_TAR -O $SRC_PATH/$LCMS_TAR || exit 1
  fi
  tar xvf $SRC_PATH/$LCMS_TAR || exit 1
  cd lcms2-* || exit 1
  CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --disable-shared --enable-static || exit 1
  make -j${MKJOBS} || exit 1
  make install || exit 1
  mkdir -p $INSTALL_PATH/docs/lcms || exit 1
  cp LIC* COP* README AUTH* CONT* $INSTALL_PATH/docs/lcms/
fi

# Install openjpeg
if [ ! -f $INSTALL_PATH/lib/pkgconfig/libopenjpeg.pc ]; then
  cd $TMP_PATH || exit 1
  if [ ! -f $SRC_PATH/$OJPG_TAR ]; then
    wget $THIRD_PARTY_SRC_URL/$OJPG_TAR -O $SRC_PATH/$OJPG_TAR || exit 1
  fi
  tar xvf $SRC_PATH/$OJPG_TAR || exit 1
  cd openjpeg-* || exit 1
  ./bootstrap.sh || exit 1
  CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --enable-shared --enable-static || exit 1
  make -j${MKJOBS} || exit 1
  make install || exit 1
  mkdir -p $INSTALL_PATH/docs/openjpeg || exit 1
  cp LIC* COP* READ* AUTH* CONT* $INSTALL_PATH/docs/openjpeg/
fi

# Install libraw
if [ ! -f $INSTALL_PATH/lib/pkgconfig/libraw.pc ]; then
  cd $TMP_PATH || exit 1
  if [ ! -f $SRC_PATH/$LIBRAW_TAR ]; then
   wget $THIRD_PARTY_SRC_URL/$LIBRAW_TAR -O $SRC_PATH/$LIBRAW_TAR || exit 1
  fi
  tar xvf $SRC_PATH/$LIBRAW_TAR || exit 1
  cd LibRaw* || exit 1
  mkdir build && cd build
  CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" cmake .. -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH -DCMAKE_BUILD_TYPE=Release || exit 1
  make -j${MKJOBS} || exit 1
  make install
  mkdir -p $INSTALL_PATH/docs/libraw || exit 1
  cp ../README ../COPYRIGHT ../LIC* $INSTALL_PATH/docs/libraw/ || exit 1
fi

# Install openexr
if [ ! -f $INSTALL_PATH/lib/pkgconfig/OpenEXR.pc ]; then
  cd $TMP_PATH || exit 1
  if [ ! -f $SRC_PATH/$ILM_TAR ]; then
    wget $THIRD_PARTY_SRC_URL/$ILM_TAR -O $SRC_PATH/$ILM_TAR || exit 1
  fi
  tar xvf $SRC_PATH/$ILM_TAR || exit 1
  cd ilmbase-* || exit 1
  CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --enable-static || exit 1
  make -j${MKJOBS} || exit 1
  make install || exit 1
  mkdir -p $INSTALL_PATH/docs/openexr || exit 1
  cp LIC* COP* README AUTH* CONT* $INSTALL_PATH/docs/openexr/

  cd $TMP_PATH || exit 1
  if [ ! -f $SRC_PATH/$EXR_TAR ]; then
    wget $THIRD_PARTY_SRC_URL/$EXR_TAR -O $SRC_PATH/$EXR_TAR || exit 1
  fi
  tar xvf $SRC_PATH/$EXR_TAR || exit 1
  cd openexr-* || exit 1
  CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --enable-static || exit 1
  make -j${MKJOBS} || exit 1
  make install || exit 1
  cp LIC* COP* README AUTH* CONT* $INSTALL_PATH/docs/openexr/
fi

# Install magick
if [ "$REBUILD_MAGICK" == "1" ]; then
  rm -rf $INSTALL_PATH/include/ImageMagick-6/ $INSTALL_PATH/lib/libMagick* $INSTALL_PATH/share/ImageMagick-6/ $INSTALL_PATH/lib/pkgconfig/{Image,Magick}*
fi
if [ ! -f $INSTALL_PATH/lib/pkgconfig/Magick++.pc ]; then
  cd $TMP_PATH || exit 1
  if [ ! -f $SRC_PATH/$MAGICK_TAR ]; then
    wget $THIRD_PARTY_SRC_URL/$MAGICK_TAR -O $SRC_PATH/$MAGICK_TAR || exit 1
  fi
  tar xvf $SRC_PATH/$MAGICK_TAR || exit 1
  cd ImageMagick-* || exit 1
  cat $INC_PATH/patches/composite-private.h > magick/composite-private.h || exit 1
  patch -p0< $INC_PATH/patches/magick-seed.diff || exit 1
  patch -p0< $INC_PATH/patches/magick-svg.diff || exit 1
  CFLAGS="$BF -DMAGICKCORE_EXCLUDE_DEPRECATED=1" CXXFLAGS="$BF -DMAGICKCORE_EXCLUDE_DEPRECATED=1" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --with-magick-plus-plus=yes --with-quantum-depth=32 --without-dps --without-djvu --without-fftw --without-fpx --without-gslib --without-gvc --without-jbig --without-jpeg --without-lcms --with-lcms2 --without-openjp2 --without-lqr --without-lzma --without-openexr --with-pango --with-png --with-rsvg --without-tiff --without-webp --with-xml --without-zlib --without-bzlib --enable-static --disable-shared --enable-hdri --with-freetype --with-fontconfig --without-x --without-modules || exit 1
  make -j${MKJOBS} || exit 1
  make install || exit 1
  mkdir -p $INSTALL_PATH/docs/imagemagick || exit 1
  cp LIC* COP* Copy* Lic* README AUTH* CONT* $INSTALL_PATH/docs/imagemagick/
fi

# Install glew
if [ ! -f $INSTALL_PATH/lib/pkgconfig/glew.pc ]; then
  cd $TMP_PATH || exit 1
  if [ ! -f $SRC_PATH/$GLEW_TAR ]; then
    wget $THIRD_PARTY_SRC_URL/$GLEW_TAR -O $SRC_PATH/$GLEW_TAR || exit 1
  fi
  tar xvf $SRC_PATH/$GLEW_TAR || exit 1
  cd glew-* || exit 1
  if [ "$ARCH" == "i686" ]; then
    make -j${MKJOBS} 'CFLAGS.EXTRA=-O2 -g -march=i686 -mtune=i686' includedir=/usr/include GLEW_DEST= libdir=/usr/lib bindir=/usr/bin || exit 1
  else
    make -j${MKJOBS} 'CFLAGS.EXTRA=-O2 -g -m64 -fPIC -mtune=generic' includedir=/usr/include GLEW_DEST= libdir=/usr/lib64 bindir=/usr/bin || exit 1
  fi
  make install GLEW_DEST=$INSTALL_PATH libdir=/lib bindir=/bin includedir=/include || exit 1
  mkdir -p $INSTALL_PATH/docs/glew || exit 1
  cp LICENSE.txt README.txt $INSTALL_PATH/docs/glew/ || exit 1
fi

# Install pixman
if [ ! -f $INSTALL_PATH/lib/pkgconfig/pixman-1.pc ]; then
  if [ ! -f $SRC_PATH/$PIX_TAR ]; then
    wget $THIRD_PARTY_SRC_URL/$PIX_TAR -O $SRC_PATH/$PIX_TAR || exit 1
  fi
  tar xvf $SRC_PATH/$PIX_TAR || exit 1
  cd pixman-* || exit 1
  CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --disable-shared --enable-static || exit 1
  make -j${MKJOBS} || exit 1
  make install || exit 1
  mkdir -p $INSTALL_PATH/docs/pixman || exit 1
  cp COPYING* README AUTHORS $INSTALL_PATH/docs/pixman/ || exit 1
fi

# Install cairo
if [ ! -f $INSTALL_PATH/lib/pkgconfig/cairo.pc ]; then
  cd $TMP_PATH || exit 1
  if [ ! -f $SRC_PATH/$CAIRO_TAR ]; then
    wget $THIRD_PARTY_SRC_URL/$CAIRO_TAR -O $SRC_PATH/$CAIRO_TAR || exit 1
  fi
  tar xvf $SRC_PATH/$CAIRO_TAR || exit 1
  cd cairo-* || exit 1
  CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include -I${INSTALL_PATH}/include/pixman-1" LDFLAGS="-L${INSTALL_PATH}/lib -lpixman-1" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --enable-static || exit 1
  make -j${MKJOBS} || exit 1
  make install || exit 1
  mkdir -p $INSTALL_PATH/docs/cairo || exit 1
  cp COPYING* README AUTHORS $INSTALL_PATH/docs/cairo/ || exit 1
fi

# Install ocio
if [ ! -f $INSTALL_PATH/lib/libOpenColorIO.so ]; then
  cd $TMP_PATH || exit 1
  if [ ! -f $SRC_PATH/$OCIO_TAR ]; then
    wget $THIRD_PARTY_SRC_URL/$OCIO_TAR -O $SRC_PATH/$OCIO_TAR || exit 1
  fi
  tar xvf $SRC_PATH/$OCIO_TAR || exit 1
  cd OpenColorIO-* || exit 1
  mkdir build || exit 1
  cd build || exit 1
  #CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" cmake .. -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH -DCMAKE_BUILD_TYPE=Release -DOCIO_BUILD_JNIGLUE=OFF -DOCIO_BUILD_NUKE=OFF -DOCIO_BUILD_SHARED=ON -DOCIO_BUILD_STATIC=OFF -DOCIO_STATIC_JNIGLUE=OFF -DUSE_EXTERNAL_LCMS=ON -DOCIO_BUILD_TRUELIGHT=OFF -DUSE_EXTERNAL_TINYXML=OFF -DUSE_EXTERNAL_YAML=OFF -DOCIO_BUILD_APPS=OFF -DOCIO_USE_BOOST_PTR=ON -DOCIO_BUILD_TESTS=OFF -DOCIO_BUILD_PYGLUE=OFF
  CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" cmake .. -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH -DCMAKE_BUILD_TYPE=Release -DOCIO_BUILD_SHARED=ON -DOCIO_BUILD_STATIC=OFF || exit 1
  # dont work, wtf! #-DUSE_EXTERNAL_LCMS=ON || exit 1
  make -j${MKJOBS} || exit 1
  make install || exit 1
  mkdir -p $INSTALL_PATH/docs/ocio || exit 1
  cp ../LICENSE ../README $INSTALL_PATH/docs/ocio/ || exit 1
fi

# Install oiio
if [ "$REBUILD_OIIO" == "1" ]; then
  rm -rf $INSTALL_PATH/lib/libOpenImage* $INSTALL_PATH/include/OpenImage*
fi
if [ ! -f $INSTALL_PATH/lib/libOpenImageIO.so ]; then
  cd $TMP_PATH || exit 1
  if [ ! -f $SRC_PATH/$OIIO_TAR ]; then
    wget $THIRD_PARTY_SRC_URL/$OIIO_TAR -O $SRC_PATH/$OIIO_TAR || exit 1
  fi
  tar xvf $SRC_PATH/$OIIO_TAR || exit 1
  cd oiio-Release-* || exit 1
  mkdir build || exit 1
  cd build || exit 1
  CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" CXXFLAGS="-fPIC" cmake -DUSE_OPENSSL:BOOL=FALSE -DOPENEXR_HOME=$INSTALL_PATH -DILMBASE_HOME=$INSTALL_PATH -DTHIRD_PARTY_TOOLS_HOME=$INSTALL_PATH -DUSE_QT:BOOL=FALSE -DUSE_TBB:BOOL=FALSE -DUSE_PYTHON:BOOL=FALSE -DUSE_FIELD3D:BOOL=FALSE -DUSE_OPENJPEG:BOOL=FALSE  -DOIIO_BUILD_TESTS=0 -DOIIO_BUILD_TOOLS=0 -DUSE_LIB_RAW=1 -DLIBRAW_PATH=$INSTALL_PATH -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH -DBOOST_ROOT=$INSTALL_PATH -DSTOP_ON_WARNING:BOOL=FALSE -DUSE_GIF:BOOL=TRUE -DUSE_FREETYPE:BOOL=TRUE -DFREETYPE_INCLUDE_PATH=$INSTALL_PATH/include -DUSE_FFMPEG:BOOL=FALSE .. || exit 1
  make -j${MKJOBS} || exit 1
  make install || exit 1
  mkdir -p $INSTALL_PATH/docs/oiio || exit 1
  cp ../LICENSE ../README* ../CREDITS $INSTALL_PATH/docs/oiio || exit 1
fi

# Install eigen
if [ ! -f $INSTALL_PATH/lib/pkgconfig/eigen2.pc ]; then
  cd $TMP_PATH || exit 1
  if [ ! -f $CWD/src/$EIGEN_TAR ]; then
    wget $THIRD_PARTY_SRC_URL/$EIGEN_TAR -O $CWD/src/$EIGEN_TAR || exit 1
  fi
  tar xvf $CWD/src/$EIGEN_TAR || exit 1
  cd eigen-* || exit 1
  rm -rf build
  mkdir build || exit 1
  cd build || exit 1
  CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" cmake .. -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH || exit 1
  make -j${MKJOBS} || exit 1
  make install || exit 1
  mkdir -p $INSTALL_PATH/docs/eigen || exit 1
  cp ../LIC* ../COP* ../README ../AUTH* ../CONT* $INSTALL_PATH/docs/eigen/
  mv $INSTALL_PATH/share/pkgconfig/* $INSTALL_PATH/lib/pkgconfig
fi

# Install opencv
#Todo: migrate to opencv 3
#if [ ! -f $INSTALL_PATH/lib/pkgconfig/opencv.pc ]; then
#  cd $TMP_PATH || exit 1
#  if [ ! -f $CWD/src/$CV_TAR ]; then
#    wget $THIRD_PARTY_SRC_URL/$CV_TAR -O $CWD/src/$CV_TAR || exit 1
#  fi
#  unzip $CWD/src/$CV_TAR || exit 1
#  cd opencv* || exit 1
#  patch -p1 < $INC_PATH/patches/opencv-pkgconfig.patch || exit 1
#  patch -p0 < $INC_PATH/patches/opencv-cmake.diff || exit 1
#  mkdir build || exit 1
#  cd build || exit 1
#  CFLAGS="$BF" CXXFLAGS="$BF" CMAKE_INCLUDE_PATH=$INSTALL_PATH/include CMAKE_LIBRARY_PATH=$INSTALL_PATH/lib CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" cmake -DWITH_GTK=OFF -DWITH_GSTREAMER=OFF -DWIDTH_FFMPEG=OFF -DWITH_OPENEXR=OFF -DWITH_OPENCL=OFF -DWITH_OPENGL=ON -DBUILD_WITH_DEBUG_INFO=OFF -DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=OFF -DBUILD_EXAMPLES=OFF -DCMAKE_BUILD_TYPE=Release -DENABLE_SSE3=OFF .. -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH || exit 1
#  make -j${MKJOBS} || exit 1
#  make install || exit 1
#  mkdir -p $INSTALL_PATH/docs/opencv || exit 1
#  cp ../LIC* ../COP* ../README ../AUTH* ../CONT* $INSTALL_PATH/docs/opencv/
#fi

# Install ffmpeg
# Todo: do a full build of ffmpeg with all dependencies (LGPL only)
if [ "$REBUILD_FFMPEG" == "1" ]; then
  rm -rf $INSTALL_PATH/bin/ff* $INSTALL_PATH/lib/libav* $INSTALL_PATH/lib/libsw* $INSTALL_PATH/include/libav* $INSTALL_PATH/lib/pkgconfig/libav*
fi
if [ ! -f $INSTALL_PATH/lib/pkgconfig/libavcodec.pc ]; then
  cd $TMP_PATH || exit 1
  if [ ! -f $SRC_PATH/$FFMPEG_TAR ]; then
    wget $THIRD_PARTY_SRC_URL/$FFMPEG_TAR -O $SRC_PATH/$FFMPEG_TAR || exit 1
  fi
  tar xvf $SRC_PATH/$FFMPEG_TAR || exit 1
  cd ffmpeg-2* || exit 1
  CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --disable-static || exit 1
  make -j${MKJOBS} || exit 1
  make install || exit 1
  mkdir -p $INSTALL_PATH/docs/ffmpeg || exit 1
  cp COPYING.LGPLv2.1 CREDITS $INSTALL_PATH/docs/ffmpeg/
fi

# Install qt
if [ ! -f $INSTALL_PATH/bin/qmake ]; then
  cd $TMP_PATH || exit 1
  if [ "$1" == "qt5" ]; then
    QT_TAR=$QT5_TAR
    QT_CONF="-no-openssl -opengl desktop -opensource -nomake examples -nomake tests -release -no-gtkstyle -confirm-license -no-c++11 -I${INSTALL_PATH}/include -L${INSTALL_PATH}/lib"
  else
    QT_TAR=$QT4_TAR
    QT_CONF="-no-multimedia -no-openssl -confirm-license -release -opensource -opengl desktop -nomake demos -nomake docs -nomake examples -no-gtkstyle -no-webkit -I${INSTALL_PATH}/include -L${INSTALL_PATH}/lib"
  fi

  if [ ! -f $SRC_PATH/$QT_TAR ]; then
    wget $THIRD_PARTY_SRC_URL/$QT_TAR -O $SRC_PATH/$QT_TAR || exit 1
  fi
  tar xvf $SRC_PATH/$QT_TAR || exit 1
  cd qt* || exit 1
  QT_SRC=$(pwd)/src
  if [ "$1" == "qt5" ]; then
    patch -p0< $INC_PATH/patches/no-egl-in-qt5.diff || exit 1
  fi
  CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure -prefix $INSTALL_PATH $QT_CONF -shared || exit 1

  # https://bugreports.qt-project.org/browse/QTBUG-5385
  LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(pwd)/lib make -j${MKJOBS} || exit  1

  make install || exit 1
  mkdir -p $INSTALL_PATH/docs/qt || exit 1
  cp README LICENSE.LGPL LGPL_EXCEPTION.txt $INSTALL_PATH/docs/qt/ || exit 1
  rm -rf $TMP_PATH/qt*
fi

# Force py3
export PYTHON_PATH=$INSTALL_PATH/lib/python3.4
export PYTHON_INCLUDE=$INSTALL_PATH/include/python3.4

# Install shiboken
if [ ! -f $INSTALL_PATH/lib/pkgconfig/shiboken.pc ]; then
  cd $TMP_PATH || exit 1
  if [ ! -f $SRC_PATH/$SHIBOK_TAR ]; then
    wget $THIRD_PARTY_SRC_URL/$SHIBOK_TAR -O $SRC_PATH/$SHIBOK_TAR || exit 1
  fi
  tar xvf $SRC_PATH/$SHIBOK_TAR || exit 1
  cd shiboken-* || exit 1
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
fi

# Install pyside
if [ ! -f $INSTALL_PATH/lib/pkgconfig/pyside.pc ]; then
  cd $TMP_PATH || exit 1
  if [ ! -f $SRC_PATH/$PYSIDE_TAR ]; then
    wget $THIRD_PARTY_SRC_URL/$PYSIDE_TAR -O $SRC_PATH/$PYSIDE_TAR || exit 1
  fi
  tar xvf $SRC_PATH/$PYSIDE_TAR || exit 1
  cd pyside-* || exit 1
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
fi

# Install SeExpr
if [ ! -f $INSTALL_PATH/lib/libSeExpr.so ]; then
  cd $TMP_PATH || exit 1
  if [ ! -f $SRC_PATH/$SEE_TAR ]; then
    wget $THIRD_PARTY_SRC_URL/$SEE_TAR -O $SRC_PATH/$SEE_TAR || exit 1
  fi
  tar xvf $SRC_PATH/$SEE_TAR || exit 1
  cd SeExpr-* || exit 1
  mkdir build || exit 1
  cd build || exit 1
  CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" cmake .. -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH || exit 1
  make || exit 1
  make install || exit 1
  mkdir -p $INSTALL_PATH/docs/seexpr || exit 1
  cp ../README ../src/doc/license.txt $INSTALL_PATH/docs/seexpr/ || exit 1
fi

# Install SSL (for installer, not working yet)
if [ "$SSL_TAR" != "" ]; then
  cd $TMP_PATH || exit 1
  if [ ! -f $SRC_PATH/$SSL_TAR ]; then
    wget $THIRD_PARTY_SRC_URL/$SSL_TAR -O $SRC_PATH/$SSL_TAR || exit 1
  fi
  tar xvf $SRC_PATH/$SSL_TAR || exit 1
  cd openssl* || exit 1
  CFLAGS="$BF" CXXFLAGS="$BF" ./config --prefix=$INSTALL_PATH || exit 1
  make || exit 1
  make install || exit 1
fi

# Install static qt4 for installer
if [ ! -f $INSTALL_PATH/qt4-static/bin/qmake ]; then
  cd $TMP_PATH || exit 1
  QTIFW_CONF="-no-multimedia -no-gif -qt-libpng -no-opengl -no-libmng -no-libtiff -no-libjpeg -static -no-openssl -confirm-license -release -opensource -nomake demos -nomake docs -nomake examples -no-gtkstyle -no-webkit -I${INSTALL_PATH}/include -L${INSTALL_PATH}/lib"

  tar xvf $SRC_PATH/$QT4_TAR || exit 1
  cd qt*4.8* || exit 1
  CFLAGS="$BF" CXXFLAGS="$BF" CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure -prefix $INSTALL_PATH/qt4-static $QTIFW_CONF || exit 1

  # https://bugreports.qt-project.org/browse/QTBUG-5385
  LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(pwd)/lib make -j${MKJOBS} || exit 1
  make install || exit 1
fi

# Install setup tools
if [ ! -f $INSTALL_PATH/bin/binarycreator ]; then
  cd $TMP_PATH || exit 1
  git clone $GIT_INSTALLER || exit 1
  cd qtifw || exit 1
  git checkout natron || exit 1
  $INSTALL_PATH/qt4-static/bin/qmake || exit 1
  make -j${MKJOBS} || exit 1
  strip -s bin/*
  cp bin/* $INSTALL_PATH/bin/ || exit 1
fi

# Done, make a tarball
cd $INSTALL_PATH/.. || exit 1
tar cvvJf $SRC_PATH/Natron-$SDK_VERSION-$SDK.tar.xz Natron-$SDK_VERSION || exit 1

echo
echo "Natron SDK Done: $SRC_PATH/Natron-$SDK_VERSION-$SDK.tar.xz"
echo
exit 0

