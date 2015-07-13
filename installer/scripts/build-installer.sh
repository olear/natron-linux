#!/bin/sh
#
# Build packages and installer for Linux and FreeBSD
# Written by Ole-André Rodlie <olear@fxarena.net>
#

source $(pwd)/common.sh || exit 1

if [ "$1" == "workshop" ]; then
  NATRON_VERSION=$TAG
  WORKSHOP=workshop-
  NATRON_BRANCH=workshop
else
  NATRON_VERSION=$NATRON_STABLE_V
  NATRON_BRANCH=stable
fi

DATE=$(date +%Y-%m-%d)

if [ "$OS" == "FreeBSD" ]; then
  INSTALL_PATH=/usr/local
  PKGOS=freebsd
  REPO_OS=freebsd$BIT
else
  PKGOS=linux
  REPO_OS=linux$BIT
fi

export LD_LIBRARY_PATH=$INSTALL_PATH/lib

if [ -d $TMP_PATH ]; then
  rm -rf $TMP_PATH || exit 1
fi
mkdir -p $TMP_PATH || exit 1

# SETUP
INSTALLER=$TMP_PATH/Natron-installer
XML=$CWD/installer/xml
QS=$CWD/installer/qs

mkdir -p $INSTALLER/config $INSTALLER/packages || exit 1
cat $CWD/installer/config/config.xml | sed "s/_VERSION_/${NATRON_VERSION}/;s/_OS_/${REPO_OS}/g;s/_BRANCH_/${NATRON_BRANCH}/g;s#_URL_#${REPO_URL}#g" > $INSTALLER/config/config.xml || exit 1
cp $CWD/installer/config/*.png $INSTALLER/config/ || exit 1

# OFX IO
OFX_IO_VERSION=$NATRON_VERSION
OFX_IO_PATH=$INSTALLER/packages/$IOPLUG_PKG
mkdir -p $OFX_IO_PATH/data $OFX_IO_PATH/meta $OFX_IO_PATH/data/Plugins || exit 1
cat $XML/openfx-io.xml | sed "s/_VERSION_/${OFX_IO_VERSION}/;s/_DATE_/${DATE}/" > $OFX_IO_PATH/meta/package.xml || exit 1
cat $QS/openfx-io.qs > $OFX_IO_PATH/meta/installscript.qs || exit 1
cat $INSTALL_PATH/docs/openfx-io/VERSION > $OFX_IO_PATH/meta/ofx-io-license.txt || exit 1
echo "" >> $OFX_IO_PATH/meta/ofx-io-license.txt || exit 1
cat $INSTALL_PATH/docs/openfx-io/LICENSE >> $OFX_IO_PATH/meta/ofx-io-license.txt || exit 1
cp -a $INSTALL_PATH/Plugins/IO.ofx.bundle $OFX_IO_PATH/data/Plugins/ || exit 1
strip -s $OFX_IO_PATH/data/Plugins/*/*/*/*
IO_LIBS=$OFX_IO_PATH/data/Plugins/IO.ofx.bundle/Libraries
mkdir -p $IO_LIBS || exit 1

OFX_DEPENDS=$(ldd $INSTALLER/packages/*/data/Plugins/*/*/*/*|grep opt | awk '{print $3}')
for x in $OFX_DEPENDS; do
  cp -v $x $IO_LIBS/ || exit 1
done

IO_LIC=$OFX_IO_PATH/meta/ofx-io-license.txt
echo "" >>$IO_LIC || exit 1
echo "" >>$IO_LIC || exit 1
echo "BOOST:" >>$IO_LIC || exit 1
echo "" >>$IO_LIC || exit 1
cat $INSTALL_PATH/docs/boost/LICENSE_1_0.txt >>$IO_LIC || exit 1

echo "" >>$IO_LIC || exit 1
echo "FFMPEG:" >>$IO_LIC || exit 1
echo "" >>$IO_LIC || exit 1
cat $INSTALL_PATH/docs/ffmpeg/COPYING.LGPLv2.1 >>$IO_LIC || exit 1

echo "" >>$IO_LIC || exit 1
echo "JPEG:" >>$IO_LIC || exit 1
echo "" >>$IO_LIC || exit 1
cat $INSTALL_PATH/docs/jpeg/README  >>$IO_LIC || exit 1

echo "" >>$IO_LIC || exit 1
echo "OPENCOLORIO:" >>$IO_LIC || exit 1
echo "" >>$IO_LIC || exit 1
cat $INSTALL_PATH/docs/ocio/LICENSE >>$IO_LIC || exit 1

echo "" >>$IO_LIC || exit 1
echo "OPENIMAGEIO:" >>$IO_LIC || exit 1
echo "" >>$IO_LIC || exit 1
cat $INSTALL_PATH/docs/oiio/LICENSE >>$IO_LIC || exit 1

echo "" >>$IO_LIC || exit 1
echo "OPENEXR:" >>$IO_LIC || exit 1
echo "" >>$IO_LIC || exit 1
cat $INSTALL_PATH/docs/openexr/LICENSE >>$IO_LIC || exit 1

echo "" >>$IO_LIC || exit 1
echo "OPENJPEG:" >>$IO_LIC || exit 1
echo "" >>$IO_LIC || exit 1
cat $INSTALL_PATH/docs/openjpeg/LICENSE >>$IO_LIC || exit 1

echo "" >>$IO_LIC || exit 1
echo "PNG:" >>$IO_LIC || exit 1
echo "" >>$IO_LIC || exit 1
cat $INSTALL_PATH/docs/png/LICENSE >>$IO_LIC || exit 1

echo "" >>$IO_LIC || exit 1
echo "TIFF:" >>$IO_LIC || exit 1
echo "" >>$IO_LIC || exit 1
cat $INSTALL_PATH/docs/tiff/COPYRIGHT >>$IO_LIC || exit 1

echo "" >>$IO_LIC || exit 1
echo "SEEXPR:" >>$IO_LIC || exit 1
echo "" >>$IO_LIC || exit 1
cat $INSTALL_PATH/docs/seexpr/license.txt >>$IO_LIC || exit 1

echo "" >>$IO_LIC || exit 1
echo "LIBRAW:" >>$IO_LIC || exit 1
echo "" >>$IO_LIC || exit 1
cat $INSTALL_PATH/docs/libraw/COPYRIGHT >>$IO_LIC || exit 1

echo "" >>$IO_LIC || exit 1
echo "JASPER:" >>$IO_LIC || exit 1
echo "" >>$IO_LIC || exit 1
cat $INSTALL_PATH/docs/jasper/COPYRIGHT >>$IO_LIC || exit 1

echo "" >>$IO_LIC || exit 1
echo "LCMS:" >>$IO_LIC || exit 1
echo "" >>$IO_LIC || exit 1
cat $INSTALL_PATH/docs/lcms/COPYING >>$IO_LIC || exit 1

# OFX MISC
OFX_MISC_VERSION=$NATRON_VERSION
OFX_MISC_PATH=$INSTALLER/packages/$MISCPLUG_PKG
mkdir -p $OFX_MISC_PATH/data $OFX_MISC_PATH/meta $OFX_MISC_PATH/data/Plugins || exit 1
cat $XML/openfx-misc.xml | sed "s/_VERSION_/${OFX_MISC_VERSION}/;s/_DATE_/${DATE}/" > $OFX_MISC_PATH/meta/package.xml || exit 1
cat $QS/openfx-misc.qs > $OFX_MISC_PATH/meta/installscript.qs || exit 1
cat $INSTALL_PATH/docs/openfx-misc/VERSION > $OFX_MISC_PATH/meta/ofx-misc-license.txt || exit 1
echo "" >> $OFX_MISC_PATH/meta/ofx-misc-license.txt || exit 1
cat $INSTALL_PATH/docs/openfx-misc/LICENSE >> $OFX_MISC_PATH/meta/ofx-misc-license.txt || exit 1
cp -a $INSTALL_PATH/Plugins/{CImg,Misc}.ofx.bundle $OFX_MISC_PATH/data/Plugins/ || exit 1
strip -s $OFX_MISC_PATH/data/Plugins/*/*/*/*

# NATRON
NATRON_PATH=$INSTALLER/packages/$NATRON_PKG
mkdir -p $NATRON_PATH/meta $NATRON_PATH/data/docs $NATRON_PATH/data/bin || exit 1
cat $XML/natron.xml | sed "s/_VERSION_/${NATRON_VERSION}/;s/_DATE_/${DATE}/" > $NATRON_PATH/meta/package.xml || exit 1
cat $QS/natron.qs > $NATRON_PATH/meta/installscript.qs || exit 1
cp -a $INSTALL_PATH/docs/natron/* $NATRON_PATH/data/docs/ || exit 1
cat $INSTALL_PATH/docs/natron/LICENSE.txt > $NATRON_PATH/meta/natron-license.txt || exit 1
cp $INSTALL_PATH/bin/Natron* $NATRON_PATH/data/bin/ || exit 1
strip -s $NATRON_PATH/data/bin/Natron $NATRON_PATH/data/bin/NatronRenderer $NATRON_PATH/data/bin/NatronCrashReporter
wget $NATRON_API_DOC || exit 1
mv natron.pdf $NATRON_PATH/data/docs/Natron_Python_API_Reference.pdf || exit 1
rm $NATRON_PATH/data/docs/TuttleOFX-README.txt || exit 1

if [ "$OS" == "GNU/Linux" ]; then
  cat $CWD/installer/scripts/Natron.sh > $NATRON_PATH/data/Natron || exit 1
  cat $CWD/installer/scripts/Natron.sh | sed "s#bin/Natron#bin/NatronRenderer#" > $NATRON_PATH/data/NatronRenderer || exit 1
  chmod +x $NATRON_PATH/data/Natron $NATRON_PATH/data/NatronRenderer || exit 1
else
  cat $CWD/installer/scripts/Natron-BSD.sh > $NATRON_PATH/data/Natron || exit 1
  cat $CWD/installer/scripts/Natron-BSD.sh | sed "s#bin/Natron#bin/NatronRenderer#" > $NATRON_PATH/data/NatronRenderer || exit 1
  chmod +x $NATRON_PATH/data/Natron $NATRON_PATH/data/NatronRenderer || exit 1
fi

# OCIO
OCIO_VERSION=$NATRON_VERSION
OCIO_PATH=$INSTALLER/packages/$PROFILES_PKG
mkdir -p $OCIO_PATH/meta $OCIO_PATH/data/share || exit 1
cat $XML/ocio.xml | sed "s/_VERSION_/${OCIO_VERSION}/;s/_DATE_/${DATE}/" > $OCIO_PATH/meta/package.xml || exit 1
cat $QS/ocio.qs > $OCIO_PATH/meta/installscript.qs || exit 1
cp -a $INSTALL_PATH/share/OpenColorIO-Configs $OCIO_PATH/data/share/ || exit 1

# Demo project
#DEMOPRO_PKG=fr.inria.natron.demopro
#DEMOPRO_V=1.0
#DEMOPRO_PATH=$INSTALLER/packages/$DEMOPRO_PKG
#mkdir -p $DEMOPRO_PATH/meta $DEMOPRO_PATH/data/Examples || exit 1
#if [ ! -f $SRC_PATH/$DEMOPRO_TAR ]; then
#  wget $SRC_URL/$DEMOPRO_TAR -O $SRC_PATH/$DEMOPRO_TAR || exit 1
#fi
#tar xvf $SRC_PATH/$DEMOPRO_TAR -C $DEMOPRO_PATH/data/Examples/ || exit 1
#(cd $DEMOPRO_PATH/data/ ; find . -type f -name ._* -exec rm -f {} \;)
#cat $XML/demopro.xml | sed "s/_DATE_/${DATE}/" > $DEMOPRO_PATH/meta/package.xml || exit 1
#cat $QS/demopro.qs > $DEMOPRO_PATH/meta/installscript.qs || exit 1 

# CORE LIBS
CLIBS_VERSION=$SDK_VERSION
CLIBS_PATH=$INSTALLER/packages/$CORELIBS_PKG
mkdir -p $CLIBS_PATH/meta $CLIBS_PATH/data/bin $CLIBS_PATH/data/lib $CLIBS_PATH/data/share/pixmaps || exit 1
cat $XML/corelibs-$WORKSHOP${PKGOS}.xml | sed "s/_VERSION_/${CLIBS_VERSION}/;s/_DATE_/${DATE}/" > $CLIBS_PATH/meta/package.xml || exit 1
cat $QS/corelibs.qs > $CLIBS_PATH/meta/installscript.qs || exit 1
cp $INSTALL_PATH/lib/libQtDBus.so.4 $CLIBS_PATH/data/lib/ || exit 1
cp $INSTALL_PATH/share/pixmaps/natronIcon256_linux.png $CLIBS_PATH/data/share/pixmaps/ || exit 1

if [ "$OS" == "GNU/Linux" ]; then
  cp -a $INSTALL_PATH/plugins/imageformats $CLIBS_PATH/data/bin/ || exit 1
  CORE_DEPENDS=$(ldd $NATRON_PATH/data/bin/*|grep opt | awk '{print $3}')
  for i in $CORE_DEPENDS; do
    cp -v $i $CLIBS_PATH/data/lib/ || exit 1
  done
  LIB_DEPENDS=$(ldd $CLIBS_PATH/data/lib/*|grep opt | awk '{print $3}')
  for y in $LIB_DEPENDS; do
    cp -v $y $CLIBS_PATH/data/lib/ || exit 1
  done
  PLUG_DEPENDS=$(ldd $CLIBS_PATH/data/bin/*/*|grep opt | awk '{print $3}')
  for z in $PLUG_DEPENDS; do
    cp -v $z $CLIBS_PATH/data/lib/ || exit 1
  done
  if [ -f $CWD/installer/misc/compat${BIT}.tgz ]; then
    tar xvf $CWD/installer/misc/compat${BIT}.tgz -C $CLIBS_PATH/data/lib/ || exit 1
  fi
else
  cp -av $INSTALL_PATH/lib/libcairo.so.11202 $CLIBS_PATH/data/lib/ || exit 1
fi

strip -s $CLIBS_PATH/data/lib/*
strip -s $CLIBS_PATH/data/bin/*/*

if [ "$OS" == "GNU/Linux" ]; then
  CORE_DOC=$CLIBS_PATH
  cat $INSTALL_PATH/docs/boost/LICENSE_1_0.txt >> $CORE_DOC/meta/3rdparty-license.txt || exit 1
  cat $INSTALL_PATH/docs/cairo/COPYING-MPL-1.1 >> $CORE_DOC/meta/3rdparty-license.txt || exit 1
  cat $INSTALL_PATH/docs/glew/LICENSE.txt >> $CORE_DOC/meta/3rdparty-license.txt || exit 1
  cat $INSTALL_PATH/docs/jpeg/README >> $CORE_DOC/meta/3rdparty-license.txt || exit 1
  cat $INSTALL_PATH/docs/png/LICENSE >> $CORE_DOC/meta/3rdparty-license.txt || exit 1
  cat $INSTALL_PATH/docs/qt/*LGPL* >> $CORE_DOC/meta/3rdparty-license.txt || exit 1
  cat $INSTALL_PATH/docs/tiff/COPYRIGHT >> $CORE_DOC/meta/3rdparty-license.txt || exit 1
  if [ "$1" == "workshop" ]; then
    cat $INSTALL_PATH/docs/python3/LICENSE >> $CORE_DOC/meta/3rdparty-license.txt || exit 1
    cat $INSTALL_PATH/docs/pyside/* >> $CORE_DOC/meta/3rdparty-license.txt || exit 1
    cat $INSTALL_PATH/docs/shibroken/* >> $CORE_DOC/meta/3rdparty-license.txt || exit 1
    cp -a $INSTALL_PATH/lib/python3.4 $CLIBS_PATH/data/lib/ || exit 1
    mkdir -p $CLIBS_PATH/data/Plugins || exit 1
    mv $CLIBS_PATH/data/lib/python3.4/site-packages/PySide $CLIBS_PATH/data/Plugins/ || exit 1
    (cd $CLIBS_PATH/data/lib/python3.4/site-packages; ln -sf ../../../Plugins/PySide . )
    rm -f $CLIBS_PATH/data/Plugins/PySide/{QtDeclarative,QtHelp,QtScript,QtScriptTools,QtSql,QtTest,QtUiTools,QtXmlPatterns}.so || exit 1
    (cd $CLIBS_PATH ; find . -type d -name __pycache__ -exec rm -rf {} \;)
    strip -s $CLIBS_PATH/data/Plugins/PySide/* $CLIBS_PATH/data/lib/python*/* $CLIBS_PATH/data/lib/python*/*/*
    rm -rf $CLIBS_PATH/data/lib/python3.4/{test,config-3.4m} || exit 1
  fi
else
  CORE_DOC=$CLIBS_PATH
  cat $INSTALL_PATH/docs/cairo/COPYING-MPL-1.1 >> $CORE_DOC/meta/3rdparty-license.txt || exit 1
fi

# OFX ARENA
OFX_ARENA_VERSION=$TAG
OFX_ARENA_PATH=$INSTALLER/packages/$ARENAPLUG_PKG
mkdir -p $OFX_ARENA_PATH/meta $OFX_ARENA_PATH/data/Plugins || exit 1
cat $XML/openfx-arena.xml | sed "s/_VERSION_/${OFX_ARENA_VERSION}/;s/_DATE_/${DATE}/" > $OFX_ARENA_PATH/meta/package.xml || exit 1
cat $QS/openfx-arena.qs > $OFX_ARENA_PATH/meta/installscript.qs || exit 1
cat $INSTALL_PATH/docs/openfx-arena/VERSION > $OFX_ARENA_PATH/meta/ofx-extra-license.txt || exit 1
echo "" >> $OFX_ARENA_PATH/meta/ofx-extra-license.txt || exit 1
cat $INSTALL_PATH/docs/openfx-arena/LICENSE >> $OFX_ARENA_PATH/meta/ofx-extra-license.txt || exit 1
cp -av $INSTALL_PATH/Plugins/Arena.ofx.bundle $OFX_ARENA_PATH/data/Plugins/ || exit 1
strip -s $OFX_ARENA_PATH/data/Plugins/*/*/*/*
echo "ImageMagick License:" >> $OFX_ARENA_PATH/meta/ofx-extra-license.txt || exit 1
cat $INSTALL_PATH/docs/imagemagick/LICENSE >> $OFX_ARENA_PATH/meta/ofx-extra-license.txt || exit 1

ARENA_LIBS=$OFX_ARENA_PATH/data/Plugins/Arena.ofx.bundle/Libraries
mkdir -p $ARENA_LIBS || exit 1
cp $INSTALL_PATH/lib/libOpenColorIO.so.1 $ARENA_LIBS/ || exit 1
cp $INSTALL_PATH/lib/liblcms2.so.2 $ARENA_LIBS/ || exit 1

# OFX CV
#OFX_CV_VERSION=$TAG
#OFX_CV_PATH=$INSTALLER/packages/$CVPLUG_PKG
#mkdir -p $OFX_CV_PATH/{data,meta} $OFX_CV_PATH/data/Plugins $OFX_CV_PATH/data/docs/openfx-opencv || exit 1
#cat $XML/openfx-opencv.xml | sed "s/_VERSION_/${OFX_CV_VERSION}/;s/_DATE_/${DATE}/" > $OFX_CV_PATH/meta/package.xml || exit 1
#cat $QS/openfx-opencv.qs > $OFX_CV_PATH/meta/installscript.qs || exit 1
#cp -a $INSTALL_PATH/docs/openfx-opencv $OFX_CV_PATH/data/docs/ || exit 1
#cat $OFX_CV_PATH/data/docs/openfx-opencv/README > $OFX_CV_PATH/meta/license.txt || exit 1
#cp -a $INSTALL_PATH/Plugins/{inpaint,segment}.ofx.bundle $OFX_CV_PATH/data/Plugins/ || exit 1
#strip -s $OFX_CV_PATH/data/Plugins/*/*/*/*
#
#mkdir -p $OFX_CV_PATH/data/lib || exit 1
#OFX_CV_DEPENDS=$(ldd $OFX_CV_PATH/data/Plugins/*/*/*/*|grep opt | awk '{print $3}')
#for x in $OFX_CV_DEPENDS; do
#  cp -v $x $OFX_CV_PATH/data/lib/ || exit 1
#done
#strip -s $OFX_CV_PATH/data/lib/*
#rm -f $OFX_CV_PATH/data/lib/libav*
#rm -f $OFX_CV_PATH/data/lib/libI*
#rm -f $OFX_CV_PATH/data/lib/libjp*
#rm -f $OFX_CV_PATH/data/lib/libpng*
#rm -f $OFX_CV_PATH/data/lib/libsw*
#rm -f $OFX_CV_PATH/data/lib/libtif*
#rm -f $OFX_CV_PATH/data/lib/libH*
#cp -a $INSTALL_PATH/docs/opencv $OFX_CV_PATH/data/docs/ || exit 1
#cat $INSTALL_PATH/docs/opencv/LICENSE >> $OFX_CV_PATH/meta/license.txt || exit 1
#
#mkdir -p $OFX_CV_PATH/data/Plugins/inpaint.ofx.bundle/Libraries || exit 1
#mv $OFX_CV_PATH/data/lib/* $OFX_CV_PATH/data/Plugins/inpaint.ofx.bundle/Libraries/ || exit 1
#(cd $OFX_CV_PATH/data/Plugins/segment.ofx.bundle; ln -sf ../inpaint.ofx.bundle/Libraries .)
#rm -rf $OFX_CV_PATH/data/lib || exit 1
#

# Clean and perms
chown root:root -R $INSTALLER/*
(cd $INSTALLER; find . -type d -name .git -exec rm -rf {} \;)

# Build repo and package
if [ "$NO_INSTALLER" != "1" ]; then
  if [ "$NATRON_BRANCH" == "workshop" ]; then
    PKG_PATH=snapshots
  else
    PKG_PATH=releases
  fi
  ONLINE_INSTALL=Natron-${PKGOS}-x86-online-${BIT}
  LOCAL_INSTALL=Natron-$NATRON_VERSION-${PKGOS}-x86-release-$BIT
  PACKAGES=fr.inria.natron,fr.inria.natron.libs,fr.inria.natron.color,fr.inria.openfx.io,fr.inria.openfx.misc,fr.inria.openfx.extra
  mkdir -p $REPO_DIR/branches/$NATRON_BRANCH/$REPO_OS/{packages,snapshots,releases} || exit 1
  $INSTALL_PATH/bin/repogen -v --update-new-components -p $INSTALLER/packages -c $INSTALLER/config/config.xml $REPO_DIR/branches/$NATRON_BRANCH/$REPO_OS/packages || exit 1
  $INSTALL_PATH/bin/binarycreator -v -f -p $INSTALLER/packages -c $INSTALLER/config/config.xml -i $PACKAGES $LOCAL_INSTALL || exit 1
  tar cvvzf $REPO_DIR/branches/$NATRON_BRANCH/$REPO_OS/$PKG_PATH/$LOCAL_INSTALL.tgz $LOCAL_INSTALL || exit 1
  if [ ! -f $REPO_DIR/branches/$NATRON_BRANCH/$REPO_OS/$PKG_PATH/$ONLINE_INSTALL.tgz ]; then
    $INSTALL_PATH/bin/binarycreator -v -n -p $INSTALLER/packages -c $INSTALLER/config/config.xml $CWD/$ONLINE_INSTALL || exit 1
    tar cvvzf $REPO_DIR/branches/$NATRON_BRANCH/$REPO_OS/$PKG_PATH/$ONLINE_INSTALL.tgz $ONLINE_INSTALL || exit 1
  fi
fi

echo "All Done!!!"
