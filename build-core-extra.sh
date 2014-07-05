#!/bin/sh
#
# Build depends for Natron Extra OFX Plugins on Linux64 (using CentOS 6.2)
# Written by Ole Andre Rodlie <olear@dracolinux.org>
#

gcc -v
sleep 5

# Dist files
PY_TAR=Python-2.7.7.tar.xz
LCMS_TAR=lcms2-2.1.tar.gz
CTL_TAR=CTL-ctl-1.5.2.tar.gz
MAGICK_TAR=ImageMagick-6.8.9-0.tar.xz
GVIZ_TAR=graphviz-2.38.0.tar.gz
EIGEN_TAR=eigen-eigen-b23437e61a07.tar.bz2
FTGL_TAR=ftgl-2.1.3-rc5.tar.gz
NUMPY_TAR=numpy-1.8.1.tar.gz
CV_TAR=opencv-2.4.9.zip

# Natron version
VERSION=0.9

# Threads
MKJOBS=4

# Setup
CWD=$(pwd)
INSTALL_PATH=/opt/Natron-$VERSION
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

# Install Python
cd $TMP_PATH || exit 1
tar xvf $CWD/../src/$PY_TAR || exit 1
cd Python* || exit 1
CFLAGS=-fPIC ./configure --prefix=$INSTALL_PATH --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1

# Install Python add-ons
cd $TMP_PATH || exit 1
tar xvf $CWD/../src/$NUMPY_TAR || exit 1
cd numpy* || exit 1
sed -e "s|#![ ]*/usr/bin/python$|#!${INSTALL_PATH}/bin/python2.7|" \
      -e "s|#![ ]*/usr/bin/env python$|#!/usr/bin/env python2.7|" \
      -e "s|#![ ]*/bin/env python$|#!/usr/bin/env python2.7|" \
      -i $(find . -name '*.py') || exit 1
CFLAGS=-fPIC LDFLAGS="$LDFLAGS -shared" python2.7 setup.py config_fc build || exit 1
CFLAGS=-fPIC LDFLAGS="$LDFLAGS -shared" python2.7 setup.py config_fc install --prefix=$INSTALL_PATH --optimize=1 || exit 1

# Install lcms
cd $TMP_PATH || exit 1
tar xvf $CWD/../src/$LCMS_TAR || exit 1
cd lcms* || exit 1
CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --disable-static || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/lcms || exit 1
cp LIC* COP* README AUTH* CONT* $INSTALL_PATH/docs/lcms/

# Install CTL
cd $TMP_PATH || exit 1
tar xvf $CWD/../src/$CTL_TAR || exit 1
cd CTL-ctl* || exit 1
mkdir build || exit 1
cd build || exit 1 
CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" cmake .. -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/ctl || exit 1
cp ../LIC* ../COP* ../README ../AUTH* ../CONT* $INSTALL_PATH/docs/ctl/

# Install Graphviz
cd $TMP_PATH || exit 1
tar xvf $CWD/../src/$GVIZ_TAR || exit 1
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

# Install Eigen
cd $TMP_PATH || exit 1
tar xvf $CWD/../src/$EIGEN_TAR || exit 1
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
tar xvf $CWD/../src/$FTGL_TAR || exit 1
cd ftgl* || exit 1
sed -i '/^SUBDIRS =/s/demo//' Makefile.in || exit 1
CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --disable-static --with-pic || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/ftgl || exit 1
cp LIC* COP* README AUTH* CONT* $INSTALL_PATH/docs/ftgl/

# Install OpenCV
cd $TMP_PATH || exit 1
unzip $CWD/../src/$CV_TAR || exit 1
cd opencv* || exit 1
patch -p1 < $CWD/opencv-pkgconfig.patch || exit 1
patch -p0 < $CWD/opencv-cmake.diff || exit 1
mkdir build || exit 1
cd build || exit 1
CMAKE_INCLUDE_PATH=$INSTALL_PATH/include CMAKE_LIBRARY_PATH=$INSTALL_PATH/lib CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" cmake -DWITH_GTK=OFF -DWITH_GSTREAMER=OFF -DOPENEXR_ROOT=$INSTALL_PATH -DOPENEXR_LIBRARIES=$INSTALL_PATH/lib -DOPENEXR_INCLUDE_DIR=$INSTALL_PATH/include -DJPEG_LIBRARY=$INSTALL_PATH/lib/libjpeg.so.9 -DJPEG_INCLUDE_DIR=$INSTALL_PATH/include -DPNG_LIBRARY=$INSTALL_PATH/lib/libpng12.so.0 -DPNG_INCLUDE_DIR=$INSTALL_PATH/include -DTIFF_LIBRARY=$INSTALL_PATH/lib/libtiff.so.5 -DTIFF_INCLUDE_DIR=$INSTALL_PATH/include -DWITH_OPENCL=OFF -DWITH_OPENGL=ON -DBUILD_WITH_DEBUG_INFO=OFF -DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=OFF -DBUILD_EXAMPLES=OFF -DCMAKE_BUILD_TYPE=Release -DENABLE_SSE3=OFF .. -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/opencv || exit 1
cp ../LIC* ../COP* ../README ../AUTH* ../CONT* $INSTALL_PATH/docs/opencv/

# Install Magick
cd $TMP_PATH || exit 1
tar xvf $CWD/../src/$MAGICK_TAR || exit 1
cd ImageMagick* || exit 1
CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" ./configure --prefix=$INSTALL_PATH --libdir=$INSTALL_PATH/lib --enable-shared --disable-static --with-xml=no --with-pango=no --with-gvc=yes || exit 1
make -j${MKJOBS} || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/imagemagick || exit 1
cp LIC* COP* README AUTH* CONT* $INSTALL_PATH/docs/imagemagick/

# Install SeExpr
cd $TMP_PATH || exit 1
git clone https://github.com/wdas/SeExpr || exit 1
cd SeExpr || exit 1
patch -p0< $CWD/seexpr.diff || exit 1
patch -p0< $CWD/seexpr2.diff || exit 1
mkdir build || exit 1
cd build || exit 1
CPPFLAGS="-I${INSTALL_PATH}/include" LDFLAGS="-L${INSTALL_PATH}/lib" cmake .. -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH || exit 1
make || exit 1
make install || exit 1
mkdir -p $INSTALL_PATH/docs/seexpr || exit 1
cp ../LIC* ../COP* ../README* ../AUTH* ../CONT* $INSTALL_PATH/docs/seexpr/

