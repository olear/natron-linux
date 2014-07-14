#!/bin/sh
#
# Written by Ole Andre Rodlie <olear@dracolinux.org>
#

gcc -v
sleep 5

# Dist files
QT4_TAR=qt-everywhere-opensource-src-4.8.6.tar.gz
QT5_TAR=qt-everywhere-opensource-src-5.3.0.tar.gz
QIFW_TAR=installer-framework-installer-framework-f586369bd5b0a876a148c203b0243a8378b45482.tar.gz
YASM_TAR=yasm-1.2.0.tar.gz
CMAKE_TAR=cmake-2.8.12.2.tar.gz
PY_TAR=Python-2.7.7.tar.xz
NUMPY_TAR=numpy-1.8.1.tar.gz
JPG_TAR=jpegsrc.v9a.tar.gz
OJPG_TAR=openjpeg-1.5.1.tar.gz
PNG_TAR=libpng-1.2.51.tar.xz
TIF_TAR=tiff-4.0.3.tar.gz
LCMS_TAR=lcms2-2.1.tar.gz
ILM_TAR=ilmbase-2.1.0.tar.gz
EXR_TAR=openexr-2.1.0.tar.gz
CTL_TAR=CTL-ctl-1.5.2.tar.gz
GLEW_TAR=glew-1.5.5.tgz
BOOST_TAR=boost_1_55_0.tar.bz2
CAIRO_TAR=cairo-1.12.0.tar.gz
FFMPEG_TAR=ffmpeg-2.2.3.tar.bz2
OCIO_TAR=imageworks-OpenColorIO-v1.0.8-0-g19ed2e3.tar.gz
OIIO_TAR=oiio-Release-1.4.9.tar.gz
EIGEN_TAR=eigen-eigen-b23437e61a07.tar.bz2
FTGL_TAR=ftgl-2.1.3-rc5.tar.gz
CV_TAR=opencv-2.4.9.zip
MAGICK_TAR=ImageMagick-6.8.9-0.tar.xz
GVIZ_TAR=graphviz-2.38.0.tar.gz

# Natron version
VERSION=0.9
SDK=SDK2

# Threads
MKJOBS=4

# Setup
CWD=$(pwd)
INSTALL_PATH=/opt/Natron-$VERSION
TMP_PATH=$CWD/tmp

if [ ! -d $INSTALL_PATH ]; then
  mkdir -p $INSTALL_PATH || exit 1
else
  rm -rf $INSTALL_PATH || exit 1
  mkdir -p $INSTALL_PATH || exit 1
  mkdir -p $INSTALL_PATH/lib
  (cd $INSTALL_PATH; ln -sf lib lib64)
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

# Install cmake (needed by openjpeg and oico/oiio ++++)
if [ ! -f /usr/local/bin/cmake ]; then
  cd $TMP_PATH || exit 1
  tar xvf $CWD/src/$CMAKE_TAR || exit 1
  cd cmake* || exit 1
  ./configure --prefix=/usr/local || exit 1
  make -j${MKJOBS} || exit 1
  make install || exit 1
fi

# Install Python
cd $TMP_PATH || exit 1
tar xvf $CWD/src/$PY_TAR || exit 1
cd Python* || exit 1
CFLAGS=-fPIC ./configure --prefix=$INSTALL_PATH --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/python || exit 1
cp LICENSE $INSTALL_PATH/docs/python/ || exit 1
(cd $INSTALL_PATH/lib ; ln -sf python2.7 python)

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
cd $TMP_PATH || exit 1
tar xvf $CWD/src/$LCMS_TAR || exit 1
cd lcms* || exit 1
CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/lcms || exit 1
cp LIC* COP* README AUTH* CONT* $INSTALL_PATH/docs/lcms/

if [ "$1" == "lcms" ]; then
  echo "Stopped after $1"
  exit 0
fi

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
patch -p1< $CWD/patches/glew-1.5.2-add-needed.patch || exit 1
patch -p1< $CWD/patches/glew-1.5.2-makefile.patch || exit 1
sed -i -e 's/\r//g' config/config.guess || exit 1
make -j${MKJOBS} 'CFLAGS.EXTRA=-O2 -g -m64 -fPIC -mtune=generic' includedir=/usr/include GLEW_DEST= libdir=/usr/lib64 bindir=/usr/bin || exit 1
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
patch -p0< $CWD/patches/stupid_cmake.diff || exit 1
patch -p0< $CWD/patches/stupid_cmake_again.diff || exit 1
mkdir build || exit 1
cd build || exit 1
CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" CXXFLAGS="-fPIC" cmake USE_OPENSSL=0 OPENJPEG_HOME=$INSTALL_PATH OPENJPEG_INCLUDE_DIR=$INSTALL_PATH/include/openjpeg-1.5 THIRD_PARTY_TOOLS_HOME=$INSTALL_PATH USE_QT=0 USE_TBB=0 USE_PYTHON=0 USE_FIELD3D=0 USE_OPENJPEG=1 USE_OCIO=1 OIIO_BUILD_TESTS=0 OIIO_BUILD_TOOLS=0 OCIO_HOME=$INSTALL_PATH -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH .. || exit 1
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
QT_CONF="-no-openssl -confirm-license -release -opensource -opengl desktop -nomake demos -nomake docs -nomake examples -no-gtkstyle -no-webkit -I${INSTALL_PATH}/include -L${INSTALL_PATH}/lib"
fi

tar xvf $CWD/src/$QT_TAR || exit 1
cd qt* || exit 1
if [ "$1" == "qt5" ]; then
  patch -p0< $CWD/patches/no-egl.diff || exit 1
fi
CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure -prefix $INSTALL_PATH $QT_CONF -shared || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/qt || exit 1
cp README LICENSE.LGPL LGPL_EXCEPTION.txt $INSTALL_PATH/docs/qt/ || exit 1
rm -rf $TMP_PATH/qt*

# QTIFW
cd $TMP_PATH || exit 1
QTIFW_CONF="-no-multimedia -no-gif -qt-libpng -no-opengl -no-libmng -no-libtiff -no-libjpeg -static -no-openssl -confirm-license -release -opensource -nomake demos -nomake docs -nomake examples -no-gtkstyle -no-webkit -I${INSTALL_PATH}/include -L${INSTALL_PATH}/lib"

tar xvf $CWD/src/$QT4_TAR || exit 1
cd qt*4.8* || exit 1
CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure -prefix $TMP_PATH/qt4 $QTIFW_CONF || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
cd ..
tar xvf $CWD/src/$QIFW_TAR || exit 1
cd installer* || exit 1
$TMP_PATH/qt4/bin/qmake || exit 1
make -j${MKJOBS} || exit 1
strip -s bin/*
cp bin/* $INSTALL_PATH/bin/ || exit 1
rm -rf $TMP_PATH/qt4

# Install numpy
cd $TMP_PATH || exit 1
tar xvf $CWD/src/$NUMPY_TAR || exit 1
cd numpy* || exit 1
sed -e "s|#![ ]*/usr/bin/python$|#!${INSTALL_PATH}/bin/python2.7|" \
      -e "s|#![ ]*/usr/bin/env python$|#!/usr/bin/env python2.7|" \
      -e "s|#![ ]*/bin/env python$|#!/usr/bin/env python2.7|" \
      -i $(find . -name '*.py') || exit 1
CFLAGS=-fPIC LDFLAGS="$LDFLAGS -shared" python2.7 setup.py config_fc build || exit 1
CFLAGS=-fPIC LDFLAGS="$LDFLAGS -shared" python2.7 setup.py config_fc install --prefix=$INSTALL_PATH --optimize=1 || exit 1

# Install CTL
cd $TMP_PATH || exit 1
tar xvf $CWD/src/$CTL_TAR || exit 1
cd CTL-ctl* || exit 1
mkdir build || exit 1
cd build || exit 1
CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" cmake .. -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/ctl || exit 1
cp ../LIC* ../COP* ../README ../AUTH* ../CONT* $INSTALL_PATH/docs/ctl/

# Install Eigen
cd $TMP_PATH || exit 1
tar xvf $CWD/src/$EIGEN_TAR || exit 1
cd eigen* || exit 1
mkdir build || exit 1
cd build || exit 1
CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" cmake .. -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/eigen || exit 1
cp ../LIC* ../COP* ../README ../AUTH* ../CONT* $INSTALL_PATH/docs/eigen/
mv $INSTALL_PATH/share/pkgconfig/* $INSTALL_PATH/lib/pkgconfig

# Install FTGL
cd $TMP_PATH || exit 1
tar xvf $CWD/src/$FTGL_TAR || exit 1
cd ftgl* || exit 1
sed -i '/^SUBDIRS =/s/demo//' Makefile.in || exit 1
CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --disable-static --with-pic || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/ftgl || exit 1
cp LIC* COP* README AUTH* CONT* $INSTALL_PATH/docs/ftgl/

# Install Graphviz
cd $TMP_PATH || exit 1
tar xvf $CWD/src/$GVIZ_TAR || exit 1
cd graphviz* || exit 1
CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --disable-static \
  --with-poppler=no \
  --with-rsvg=no \
  --with-ghostscript=no \
  --with-pangocairo=no \
  --with-gdk=no \
  --with-gdk-pixbuf=no \
  --with-gtk=no \
  --with-gtkgl=no \
  --with-gtkglext=no \
  --with-glade=no \
  --with-qt=no --with-python=no --with-perl=no || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/graphviz || exit 1
cp LIC* COP* README AUTH* CONT* $INSTALL_PATH/docs/graphviz/

# Install OpenCV
cd $TMP_PATH || exit 1
unzip $CWD/src/$CV_TAR || exit 1
cd opencv* || exit 1
patch -p1 < $CWD/patches/opencv-pkgconfig.patch || exit 1
patch -p0 < $CWD/patches/opencv-cmake.diff || exit 1
mkdir build || exit 1
cd build || exit 1
CMAKE_INCLUDE_PATH=$INSTALL_PATH/include CMAKE_LIBRARY_PATH=$INSTALL_PATH/lib CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" cmake -DWITH_GTK=OFF -DWITH_GSTREAMER=OFF -DOPENEXR_ROOT=$INSTALL_PATH -DOPENEXR_LIBRARIES=$INSTALL_PATH/lib -DOPENEXR_INCLUDE_DIR=$INSTALL_PATH/include -DJPEG_LIBRARY=$INSTALL_PATH/lib/libjpeg.so.9 -DJPEG_INCLUDE_DIR=$INSTALL_PATH/include -DPNG_LIBRARY=$INSTALL_PATH/lib/libpng12.so.0 -DPNG_INCLUDE_DIR=$INSTALL_PATH/include -DTIFF_LIBRARY=$INSTALL_PATH/lib/libtiff.so.5 -DTIFF_INCLUDE_DIR=$INSTALL_PATH/include -DWITH_OPENCL=OFF -DWITH_OPENGL=ON -DBUILD_WITH_DEBUG_INFO=OFF -DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=OFF -DBUILD_EXAMPLES=OFF -DCMAKE_BUILD_TYPE=Release -DENABLE_SSE3=OFF .. -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/opencv || exit 1
cp ../LIC* ../COP* ../README ../AUTH* ../CONT* $INSTALL_PATH/docs/opencv/

# Install Magick
cd $TMP_PATH || exit 1
tar xvf $CWD/src/$MAGICK_TAR || exit 1
cd ImageMagick* || exit 1
CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --disable-static --with-x11=no --with-freetype=no --with-xml=no --with-pango=no --with-gvc=no || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/imagemagick || exit 1
cp LIC* COP* README AUTH* CONT* $INSTALL_PATH/docs/imagemagick/

# Install SeExpr
cd $TMP_PATH || exit 1
git clone https://github.com/wdas/SeExpr || exit 1
cd SeExpr || exit 1
SEE_GIT_VERSION=$(git log|head -1|awk '{print $2}')
(cd ..;
  cp -a SeExpr SeExpr-$SEE_GIT_VERSION
  (cd SeExpr-$SEE_GIT_VERSION ; find . -type d -name .git -exec rm -rf {} \;)
  tar cvvzf $CWD/src/SeExpr-$SEE_GIT_VERSION.tar.gz SeExpr-$SEE_GIT_VERSION
)
patch -p0< $CWD/patches/seexpr.diff || exit 1
patch -p0< $CWD/patches/seexpr2.diff || exit 1
mkdir build || exit 1
cd build || exit 1
CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" cmake .. -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH || exit 1
make || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/seexpr || exit 1
cp ../LIC* ../COP* ../README* ../AUTH* ../CONT* $INSTALL_PATH/docs/seexpr/
echo $SEE_GIT_VERSION > $INSTALL_PATH/docs/seexpr/VERSION || exit 1


# SDK DONE
cd $INSTALL_PATH/.. || exit 1
tar cvvJf $CWD/src/Natron-$VERSION-$SDK.tar.xz Natron-$VERSION || exit 1

echo "Natron SDK Done!"
echo "Use $CWD/src/Natron-$VERSION-$SDK.tar.xz for future builds, only rebuild on bugs or security issues."
echo
