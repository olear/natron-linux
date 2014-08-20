#!/bin/sh
#
# Build packages and installer for Linux and FreeBSD
# Written by Ole Andre Rodlie <olear@dracolinux.org>
#

if [ "$1" == "workshop" ]; then
  NATRON_VERSION=$(cat WORKSHOP)
else
  NATRON_VERSION=$(cat STABLE)
fi

SDK_VERSION=1.0

SF_PROJECT=dracolinux
SF_REPO=natron

if [ "$1" == "workshop" ]; then
  SF_BRANCH=workshop
else
  SF_BRANCH=$(cat BRANCH)
fi

DATE=$(date +%Y-%m-%d)
DATE_NUM=$(echo $DATE | sed 's/-//g')

# Arch
if [ -z "$ARCH" ]; then
  case "$( uname -m )" in
    i?86) export ARCH=i686 ;;
    amd64) export ARCH=x86_64 ;;
       *) export ARCH=$( uname -m ) ;;
  esac
fi
if [ "$ARCH" = "i686" ]; then
  BIT=32
elif [ "$ARCH" = "x86_64" ]; then
  BIT=64
fi
OS=$(uname -o)

if [ "$OS" == "FreeBSD" ]; then
  SF_OS=freebsd$BIT
else
  SF_OS=linux$BIT
fi

CWD=$(pwd)

if [ "$OS" == "FreeBSD" ]; then
  INSTALL_PATH=/usr/local
  PKGOS=FreeBSD
else
  INSTALL_PATH=/opt/Natron-$SDK_VERSION
  PKGOS=Linux
fi

TMP_PATH=$CWD/tmp
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
cat $CWD/installer/config/config-$PKGOS.xml | sed "s/_VERSION_/${NATRON_VERSION}/;s/_PROJECT_/${SF_PROJECT}/g;s/_REPO_/${SF_REPO}/g;s/_OS_/${SF_OS}/g;s/_BRANCH_/${SF_BRANCH}/g" > $INSTALLER/config/config.xml || exit 1
cp $CWD/installer/config/*.png $INSTALLER/config/ || exit 1

# OFX IO
OFX_IO_VERSION=$NATRON_VERSION
OFX_IO_PATH=$INSTALLER/packages/net.sf.ofx.io
mkdir -p $OFX_IO_PATH/data $OFX_IO_PATH/meta $OFX_IO_PATH/data/Plugins $OFX_IO_PATH/data/docs/openfx-io || exit 1
cat $XML/openfx-io.xml | sed "s/_VERSION_/${OFX_IO_VERSION}/;s/_DATE_/${DATE}/" > $OFX_IO_PATH/meta/package.xml || exit 1
cat $QS/openfx-io.qs > $OFX_IO_PATH/meta/installscript.qs || exit 1
cp -a $INSTALL_PATH/docs/openfx-io $OFX_IO_PATH/data/docs/ || exit 1
cat $OFX_IO_PATH/data/docs/openfx-io/LICENSE > $OFX_IO_PATH/meta/license.txt || exit 1
cp -a $INSTALL_PATH/Plugins/IO.ofx.bundle $OFX_IO_PATH/data/Plugins/ || exit 1
strip -s $OFX_IO_PATH/data/Plugins/*/*/*/*

# OFX MISC
#OFX_MISC_VERSION=$NATRON_VERSION
OFX_MISC_VERSION=20140820.1
OFX_MISC_PATH=$INSTALLER/packages/net.sf.ofx.misc
mkdir -p $OFX_MISC_PATH/data $OFX_MISC_PATH/meta $OFX_MISC_PATH/data/Plugins $OFX_MISC_PATH/data/docs/openfx-misc || exit 1
cat $XML/openfx-misc.xml | sed "s/_VERSION_/${OFX_MISC_VERSION}/;s/_DATE_/${DATE}/" > $OFX_MISC_PATH/meta/package.xml || exit 1
cat $QS/openfx-misc.qs > $OFX_MISC_PATH/meta/installscript.qs || exit 1
cp -a $INSTALL_PATH/docs/openfx-misc $OFX_MISC_PATH/data/docs/ || exit 1
cat $OFX_MISC_PATH/data/docs/openfx-misc/LICENSE > $OFX_MISC_PATH/meta/license.txt || exit 1
cp -a $INSTALL_PATH/Plugins/Misc.ofx.bundle $OFX_MISC_PATH/data/Plugins/ || exit 1
strip -s $OFX_MISC_PATH/data/Plugins/*/*/*/*

# NATRON
NATRON_PATH=$INSTALLER/packages/fr.inria.natron
mkdir -p $NATRON_PATH/meta $NATRON_PATH/data/docs/natron $NATRON_PATH/data/bin || exit 1
cat $XML/natron.xml | sed "s/_VERSION_/${NATRON_VERSION}/;s/_DATE_/${DATE}/" > $NATRON_PATH/meta/package.xml || exit 1
cat $QS/natron.qs > $NATRON_PATH/meta/installscript.qs || exit 1
cp -a $INSTALL_PATH/docs/natron $NATRON_PATH/data/docs/ || exit 1
cat $NATRON_PATH/data/docs/natron/LICENSE.txt > $NATRON_PATH/meta/license.txt || exit 1
cp $INSTALL_PATH/bin/Natron $INSTALL_PATH/bin/NatronRenderer $INSTALL_PATH/bin/Natron.debug $NATRON_PATH/data/bin/ || exit 1
strip -s $NATRON_PATH/data/bin/*

if [ "$OS" == "GNU/Linux" ]; then
  cat $CWD/installer/Natron.sh > $NATRON_PATH/data/Natron || exit 1
  cat $CWD/installer/Natron.sh | sed "s#bin/Natron#bin/NatronRenderer#" > $NATRON_PATH/data/NatronRenderer || exit 1
  cat $CWD/installer/Natron-portable.sh > $NATRON_PATH/data/Natron-portable || exit 1
  cat $CWD/installer/Natron-portable.sh | sed "s#bin/Natron#bin/NatronRenderer#" > $NATRON_PATH/data/NatronRenderer-portable || exit 1
  chmod +x $NATRON_PATH/data/{Natron,Natron-portable} $NATRON_PATH/data/{NatronRenderer,NatronRenderer-portable} || exit 1
else
  cat $CWD/installer/Natron-BSD.sh > $NATRON_PATH/data/Natron || exit 1
  cat $CWD/installer/Natron-BSD.sh | sed "s#bin/Natron#bin/NatronRenderer#" > $NATRON_PATH/data/NatronRenderer || exit 1
  chmod +x $NATRON_PATH/data/Natron $NATRON_PATH/data/NatronRenderer || exit 1
fi

# OCIO
#OCIO_VERSION=$NATRON_VERSION
OCIO_VERSION=20140820.1
OCIO_PATH=$INSTALLER/packages/fr.inria.ocio
mkdir -p $OCIO_PATH/meta $OCIO_PATH/data/share || exit 1
cat $XML/ocio.xml | sed "s/_VERSION_/${OCIO_VERSION}/;s/_DATE_/${DATE}/" > $OCIO_PATH/meta/package.xml || exit 1
cat $QS/ocio.qs > $OCIO_PATH/meta/installscript.qs || exit 1
cp -a $INSTALL_PATH/share/OpenColorIO-Configs $OCIO_PATH/data/share/ || exit 1

# CORE LIBS
CLIBS_VERSION=$SDK_VERSION
CLIBS_PATH=$INSTALLER/packages/fr.inria.corelibs
mkdir -p $CLIBS_PATH/meta $CLIBS_PATH/data/bin $CLIBS_PATH/data/lib $CLIBS_PATH/data/share/pixmaps || exit 1
cat $XML/corelibs-$PKGOS.xml | sed "s/_VERSION_/${CLIBS_VERSION}/;s/_DATE_/${DATE}/" > $CLIBS_PATH/meta/package.xml || exit 1
cat $QS/corelibs.qs > $CLIBS_PATH/meta/installscript.qs || exit 1

cp $INSTALL_PATH/share/pixmaps/natronIcon256_linux.png $CLIBS_PATH/data/share/pixmaps/ || exit 1

if [ "$OS" == "GNU/Linux" ]; then
cp -a $INSTALL_PATH/plugins/{bearer,iconengines,imageformats,graphicssystems} $CLIBS_PATH/data/bin/ || exit 1

CORE_DEPENDS=$(ldd $NATRON_PATH/data/bin/*|grep opt | awk '{print $3}')
for i in $CORE_DEPENDS; do
  cp -v $i $CLIBS_PATH/data/lib/ || exit 1
done

OFX_DEPENDS=$(ldd $INSTALLER/packages/*/data/Plugins/*/*/*/*|grep opt | awk '{print $3}')
for x in $OFX_DEPENDS; do
  cp -v $x $CLIBS_PATH/data/lib/ || exit 1
done

LIB_DEPENDS=$(ldd $CLIBS_PATH/data/lib/*|grep opt | awk '{print $3}')
for y in $LIB_DEPENDS; do
  cp -v $y $CLIBS_PATH/data/lib/ || exit 1
done

PLUG_DEPENDS=$(ldd $CLIBS_PATH/data/bin/*/*|grep opt | awk '{print $3}')
for z in $PLUG_DEPENDS; do
  cp -v $z $CLIBS_PATH/data/lib/ || exit 1
done

if [ -f $CWD/installer/compat${BIT}.tgz ]; then
  tar xvf $CWD/installer/compat${BIT}.tgz -C $CLIBS_PATH/data/lib/ || exit 1
fi

else
  cp -av $INSTALL_PATH/lib/libcairo.so.11202 $CLIBS_PATH/data/lib/ || exit 1
  # PC-BSD compat
  cp -av $INSTALL_PATH/lib/libOpenImageIO.so.1.4.9 $CLIBS_PATH/data/lib/libOpenImageIO.so.1.4 || exit 1
fi

strip -s $CLIBS_PATH/data/lib/*
strip -s $CLIBS_PATH/data/bin/*/*

if [ "$OS" == "GNU/Linux" ]; then
CORE_DOC=$CLIBS_PATH
cp -a $INSTALL_PATH/docs $CORE_DOC/data/ || exit 1
rm -rf $CORE_DOC/data/docs/{natron,openfx*} || exit 1
rm -rf $CORE_DOC/data/docs/{ctl,eigen,ftgl,graphviz,imagemagick,opencv,python,seexpr,tuttleofx} 
cp $CORE_DOC/data/docs/boost/LICENSE_1_0.txt $CORE_DOC/meta/boost_license.txt || exit 1
cp $CORE_DOC/data/docs/cairo/COPYING-MPL-1.1 $CORE_DOC/meta/cairo_license.txt || exit 1
rm -rf $CORE_DOC/data/docs/cairo/*LGPL*
cp $CORE_DOC/data/docs/ffmpeg/COPYING.LGPLv2.1 $CORE_DOC/meta/ffmpeg_license.txt || exit 1
cp $CORE_DOC/data/docs/glew/LICENSE.txt $CORE_DOC/meta/glew_license.txt || exit 1
cp $CORE_DOC/data/docs/jpeg/README $CORE_DOC/meta/jpeg_license.txt || exit 1
cp $CORE_DOC/data/docs/ocio/LICENSE $CORE_DOC/meta/ocio_license.txt || exit 1
cp $CORE_DOC/data/docs/oiio/LICENSE $CORE_DOC/meta/oiio_license.txt || exit 1
cp $CORE_DOC/data/docs/openexr/LICENSE $CORE_DOC/meta/openexr_license.txt || exit 1
cp $CORE_DOC/data/docs/openjpeg/LICENSE $CORE_DOC/meta/openjpeg_license.txt || exit 1
cp $CORE_DOC/data/docs/png/LICENSE $CORE_DOC/meta/png_license.txt || exit 1
cat $CORE_DOC/data/docs/qt/*LGPL* > $CORE_DOC/meta/qt_license.txt || exit 1
cp $CORE_DOC/data/docs/tiff/COPYRIGHT $CORE_DOC/meta/tiff_license.txt || exit 1
else
CORE_DOC=$CLIBS_PATH
cp $INSTALL_PATH/docs/cairo/COPYING-MPL-1.1 $CORE_DOC/meta/cairo_license.txt || exit 1
cp $INSTALL_PATH/share/doc/openimageio/LICENSE $CORE_DOC/meta/oiio_license.txt || exit 1
fi

chown root:root -R $INSTALLER/*
(cd $INSTALLER; find . -type d -name .git -exec rm -rf {} \;)

if [ ! -d $CWD/repo/$SF_OS/$SF_BRANCH ]; then
  mkdir -p $CWD/repo/$SF_OS/$SF_BRANCH || exit 1
fi
mkdir -p $CWD/repo/${SF_OS}/$SF_BRANCH/releases $CWD/repo/${SF_OS}/$SF_BRANCH/repo || exit 1

if [ "$1" != "workshop" ]; then
TGZ=$TMP_PATH/Natron_${PKGOS}_x86-${BIT}bit_v$NATRON_VERSION
rm -rf $TGZ
mkdir -p $TGZ || exit 1
cp -av $INSTALLER/packages/*/data/* $TGZ/ || exit 1
( cd $TMP_PATH ; tar cvvzf Natron_${PKGOS}_x86-${BIT}bit_v$NATRON_VERSION.tgz Natron_${PKGOS}_x86-${BIT}bit_v$NATRON_VERSION)
mv $TGZ.tgz $CWD/repo/$SF_OS/$SF_BRANCH/releases/ || exit 1
fi

# OFX YADIF
#OFX_YADIF_VERSION=20140713
#OFX_YADIF_PATH=$INSTALLER/packages/net.sf.ofx.yadif
#mkdir -p $OFX_YADIF_PATH/{data,meta} $OFX_YADIF_PATH/data/Plugins $OFX_YADIF_PATH/data/docs/openfx-yadif || exit 1
#cat $XML/openfx-yadif.xml | sed "s/_VERSION_/${OFX_YADIF_VERSION}/;s/_DATE_/${DATE}/" > $OFX_YADIF_PATH/meta/package.xml || exit 1
#cat $QS/openfx-yadif.qs > $OFX_YADIF_PATH/meta/installscript.qs || exit 1
#cp -a $INSTALL_PATH/docs/openfx-yadif $OFX_YADIF_PATH/data/docs/ || exit 1
#cat $OFX_YADIF_PATH/data/docs/openfx-yadif/README.md > $OFX_YADIF_PATH/meta/license.txt || exit 1
#cp -a $INSTALL_PATH/Plugins/yadif.ofx.bundle $OFX_YADIF_PATH/data/Plugins/ || exit 1
#strip -s $OFX_YADIF_PATH/data/Plugins/*/*/*/*
#mkdir -p $OFX_YADIF_PATH/data/lib || exit 1

#OFX_DEPENDS=$(ldd $OFX_YADIF_PATH/data/Plugins/*/*/*/*|grep opt | awk '{print $3}')
#for x in $OFX_DEPENDS; do
#  cp -v $x $OFX_YADIF_PATH/data/lib/ || exit 1
#done
#strip -s $OFX_YADIF_PATH/data/lib/*

# OFX OpenCV
if [ "$OS" == "GNU/Linux" ]; then
OFX_CV_VERSION=20140713
OFX_CV_PATH=$INSTALLER/packages/net.sf.ofx.opencv
mkdir -p $OFX_CV_PATH/{data,meta} $OFX_CV_PATH/data/Plugins $OFX_CV_PATH/data/docs/openfx-opencv || exit 1
cat $XML/openfx-opencv.xml | sed "s/_VERSION_/${OFX_CV_VERSION}/;s/_DATE_/${DATE}/" > $OFX_CV_PATH/meta/package.xml || exit 1
cat $QS/openfx-opencv.qs > $OFX_CV_PATH/meta/installscript.qs || exit 1
cp -a $INSTALL_PATH/docs/openfx-opencv $OFX_CV_PATH/data/docs/ || exit 1
cat $OFX_CV_PATH/data/docs/openfx-opencv/README > $OFX_CV_PATH/meta/license.txt || exit 1
cp -a $INSTALL_PATH/Plugins/{inpaint,segment}.ofx.bundle $OFX_CV_PATH/data/Plugins/ || exit 1
strip -s $OFX_CV_PATH/data/Plugins/*/*/*/*
mkdir -p $OFX_CV_PATH/data/lib || exit 1

OFX_DEPENDS=$(ldd $OFX_CV_PATH/data/Plugins/*/*/*/*|grep opt | awk '{print $3}')
for x in $OFX_DEPENDS; do
  cp -v $x $OFX_CV_PATH/data/lib/ || exit 1
done
strip -s $OFX_CV_PATH/data/lib/*
rm -f $OFX_CV_PATH/data/lib/libav*
rm -f $OFX_CV_PATH/data/lib/libI*
rm -f $OFX_CV_PATH/data/lib/libjp*
rm -f $OFX_CV_PATH/data/lib/libpng*
rm -f $OFX_CV_PATH/data/lib/libsw*
rm -f $OFX_CV_PATH/data/lib/libtif*
rm -f $OFX_CV_PATH/data/lib/libH*
cp -a $INSTALL_PATH/docs/opencv $OFX_CV_PATH/data/docs/ || exit 1
cat $INSTALL_PATH/docs/opencv/LICENSE > $OFX_CV_PATH/meta/opencv-license.txt || exit 1

# OFX TUTTLE
TUTTLE_VERSION=0.8
TUTTLE_PATH=$INSTALLER/packages/org.tuttleofx.plugins
mkdir -p $TUTTLE_PATH/{data,meta} $TUTTLE_PATH/data/{lib,Plugins,docs} || exit 1
cat $XML/tuttleofx.xml | sed "s/_VERSION_/${TUTTLE_VERSION}/;s/_DATE_/${DATE}/" > $TUTTLE_PATH/meta/package.xml || exit 1
cat $QS/tuttleofx.qs > $TUTTLE_PATH/meta/installscript.qs || exit 1
cp -a $INSTALL_PATH/docs/tuttleofx $TUTTLE_PATH/data/docs/ || exit 1
cat $TUTTLE_PATH/data/docs/tuttleofx/LICENSE.LGPL > $TUTTLE_PATH/meta/license.txt || exit 1
PLUGINS="AnisotropicDiffusion-1.1 BitDepth-1.0 Blur-1.0 Checkerboard-2.0 ColorBars-2.0 ColorCube-2.0 ColorGradation-1.0 ColorSuppress-2.0 ColorTransfer-2.0 ColorWheel-2.0 Component-1.0 Constant-2.0 Crop-1.1 Flip-1.0 FloodFill-1.0 Gamma-1.0 IdKeyer-1.0 Invert-1.0 LensDistort-2.2 LocalMaxima-1.0 MathOperator-1.0 Merge-1.0 NlmDenoiser-1.2 Normalize-1.0 Pinning-1.0 PushPixel-1.2 Ramp-2.0 Resize-1.0 SeExpr-1.0 Sobel-1.0 Text-4.0 Thinning-1.0 TimeShift-1.0"
for i in $PLUGINS; do
  cp -a $INSTALL_PATH/Plugins/${i}.ofx.bundle $TUTTLE_PATH/data/Plugins/ || exit 1
done 
strip -s $TUTTLE_PATH/data/Plugins/*/*/Linux*/*

mkdir -p $TUTTLE_PATH/data/{bin,lib} || exit 1
TUTTLE_DEPENDS=$(ldd $TUTTLE_PATH/data/Plugins/*/*/*/*|grep opt | awk '{print $3}')
for x in $TUTTLE_DEPENDS; do
  cp -v $x $TUTTLE_PATH/data/lib/ || exit 1
done
cp -a $INSTALL_PATH/bin/python $INSTALL_PATH/bin/python2 $INSTALL_PATH/bin/python2.7 $TUTTLE_PATH/data/bin/ || exit 1
rm -f $TUTTLE_PATH/data/lib/libboost_{filesystem,regex,serialization,system,thread}*
strip -s $TUTTLE_PATH/data/lib/*
strip -s $TUTTLE_PATH/data/bin/*
cp -a $INSTALL_PATH/docs/python $INSTALL_PATH/docs/seexpr $TUTTLE_PATH/data/docs/ || exit 1
cat $INSTALL_PATH/docs/python/LICENSE > $TUTTLE_PATH/meta/python-license.txt || exit 1
cat $INSTALL_PATH/docs/seexpr/LICENSE > $TUTTLE_PATH/meta/seexpr-license.txt || exit 1

fi # end linux plugins

chown root:root -R $INSTALLER/*
(cd $INSTALLER; find . -type d -name .git -exec rm -rf {} \;)

echo "Done!"

$INSTALL_PATH/bin/repogen -v --update-new-components -p $INSTALLER/packages -c $INSTALLER/config/config.xml $CWD/repo/$SF_OS/$SF_BRANCH/repo || exit 1

if [ "$1" != "workshop" ]; then
$INSTALL_PATH/bin/binarycreator -v -f -p $INSTALLER/packages -c $INSTALLER/config/config.xml -i fr.inria.natron,fr.inria.corelibs,fr.inria.ocio,net.sf.ofx.io,net.sf.ofx.misc $CWD/Natron_${PKGOS}_install_x86-${BIT}bit_v$NATRON_VERSION || exit 1
tar cvvzf repo/$SF_OS/$SF_BRANCH/releases/Natron_${PKGOS}_install_x86-${BIT}bit_v$NATRON_VERSION.tgz Natron_${PKGOS}_install_x86-${BIT}bit_v$NATRON_VERSION || exit 1

$INSTALL_PATH/bin/binarycreator -v -f -p $INSTALLER/packages -c $INSTALLER/config/config.xml $CWD/Natron_${PKGOS}_bundle_install_x86-${BIT}bit_v$NATRON_VERSION || exit 1
tar cvvzf repo/$SF_OS/$SF_BRANCH/releases/Natron_${PKGOS}_bundle_install_x86-${BIT}bit_v$NATRON_VERSION.tgz Natron_${PKGOS}_bundle_install_x86-${BIT}bit_v$NATRON_VERSION || exit 1
fi

$INSTALL_PATH/bin/binarycreator -v -n -p $INSTALLER/packages -c $INSTALLER/config/config.xml $CWD/Natron_${PKGOS}_online_install_x86-${BIT}bit_v$SF_BRANCH || exit 1
tar cvvzf repo/$SF_OS/$SF_BRANCH/releases/Natron_${PKGOS}_online_install_x86-${BIT}bit_v$SF_BRANCH.tgz Natron_${PKGOS}_online_install_x86-${BIT}bit_v$SF_BRANCH || exit 1

echo "All Done!!! ... test then upload"
