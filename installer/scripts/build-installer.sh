#!/bin/sh
#
# Build packages and installer for Linux and FreeBSD
# Written by Ole-André Rodlie <olear@fxarena.net>
#

if [ "$1" == "workshop" ]; then
  NATRON_VERSION=$(cat tags/NATRON_WORKSHOP_PKG)
  SNAPSHOT=snapshots-
  WORKSHOP=workshop-
else
  NATRON_VERSION=$(cat tags/STABLE)
fi

SDK_VERSION=2.0

SF_PROJECT=dracolinux
SF_REPO=natron

if [ "$1" == "workshop" ]; then
  SF_BRANCH=workshop
else
  SF_BRANCH=$(cat tags/BRANCH)
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
cat $CWD/installer/config/config-$SNAPSHOT${PKGOS}.xml | sed "s/_VERSION_/${NATRON_VERSION}/;s/_PROJECT_/${SF_PROJECT}/g;s/_REPO_/${SF_REPO}/g;s/_OS_/${SF_OS}/g;s/_BRANCH_/${SF_BRANCH}/g" > $INSTALLER/config/config.xml || exit 1
cp $CWD/installer/config/*.png $INSTALLER/config/ || exit 1

# OFX IO
if [ "$1" == "workshop" ]; then
  OFX_IO_VERSION=$(cat $CWD/tags/IO_WORKSHOP_PKG)
else
  OFX_IO_VERSION=$NATRON_VERSION
fi
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
if [ "$1" == "workshop" ]; then
  OFX_MISC_VERSION=$(cat $CWD/tags/MISC_WORKSHOP_PKG)
else
  OFX_MISC_VERSION=$NATRON_VERSION
fi
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
strip -s $NATRON_PATH/data/bin/Natron $NATRON_PATH/data/bin/NatronRenderer

if [ "$OS" == "GNU/Linux" ]; then
  cat $CWD/installer/Natron.sh > $NATRON_PATH/data/Natron || exit 1
  cat $CWD/installer/Natron.sh | sed "s#bin/Natron#bin/NatronRenderer#" > $NATRON_PATH/data/NatronRenderer || exit 1
  chmod +x $NATRON_PATH/data/Natron $NATRON_PATH/data/NatronRenderer || exit 1
else
  cat $CWD/installer/Natron-BSD.sh > $NATRON_PATH/data/Natron || exit 1
  cat $CWD/installer/Natron-BSD.sh | sed "s#bin/Natron#bin/NatronRenderer#" > $NATRON_PATH/data/NatronRenderer || exit 1
  chmod +x $NATRON_PATH/data/Natron $NATRON_PATH/data/NatronRenderer || exit 1
fi

# OCIO
OCIO_VERSION=$NATRON_VERSION
#OCIO_VERSION=0.9.6
OCIO_PATH=$INSTALLER/packages/fr.inria.ocio
mkdir -p $OCIO_PATH/meta $OCIO_PATH/data/share || exit 1
cat $XML/ocio.xml | sed "s/_VERSION_/${OCIO_VERSION}/;s/_DATE_/${DATE}/" > $OCIO_PATH/meta/package.xml || exit 1
cat $QS/ocio.qs > $OCIO_PATH/meta/installscript.qs || exit 1
cp -a $INSTALL_PATH/share/OpenColorIO-Configs $OCIO_PATH/data/share/ || exit 1

# CORE LIBS
CLIBS_VERSION=$SDK_VERSION
CLIBS_PATH=$INSTALLER/packages/fr.inria.corelibs
mkdir -p $CLIBS_PATH/meta $CLIBS_PATH/data/bin $CLIBS_PATH/data/lib $CLIBS_PATH/data/share/pixmaps || exit 1
cat $XML/corelibs-$WORKSHOP${PKGOS}.xml | sed "s/_VERSION_/${CLIBS_VERSION}/;s/_DATE_/${DATE}/" > $CLIBS_PATH/meta/package.xml || exit 1
cat $QS/corelibs.qs > $CLIBS_PATH/meta/installscript.qs || exit 1

cp $INSTALL_PATH/share/pixmaps/natronIcon256_linux.png $CLIBS_PATH/data/share/pixmaps/ || exit 1

if [ "$OS" == "GNU/Linux" ]; then
cp -a $INSTALL_PATH/plugins/{iconengines,imageformats,graphicssystems} $CLIBS_PATH/data/bin/ || exit 1
if [ "$1" == "workshop" ]; then
cp -a $INSTALL_PATH/lib/python3.4 $CLIBS_PATH/data/lib/ || exit 1
cp -a $INSTALL_PATH/bin/python3* $CLIBS_PATH/data/bin/ || exit 1
rm -rf $CLIBS_PATH/data/bin/python*config || exit 1
rm -rf $CLIBS_PATH/data/lib/python3.4/config* $CLIBS/data/lib/python3.4/test || exit 1
rm -f $CLIBS_PATH/data/lib/python3.4/site-packages/PySide/{QtDeclarative.so,QtHelp.so,QtScript.so,QtScriptTools.so,QtSql.so,QtTest.so,QtUiTools.so,QtXml.so,QtXmlPatterns.so}
strip -s $CLIBS_PATH/data/lib/python3.4/site-packages/*
strip -s $CLIBS_PATH/data/lib/python3.4/sites/packages/*/*
fi

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

#if [ -f $CWD/installer/compat${BIT}.tgz ]; then
#  tar xvf $CWD/installer/compat${BIT}.tgz -C $CLIBS_PATH/data/lib/ || exit 1
#fi

else
  cp -av $INSTALL_PATH/lib/libcairo.so.11202 $CLIBS_PATH/data/lib/ || exit 1
  # PC-BSD compat
  cp -av $INSTALL_PATH/lib/libOpenImageIO.so.1.4.15 $CLIBS_PATH/data/lib/libOpenImageIO.so.1.4 || exit 1
fi

strip -s $CLIBS_PATH/data/lib/*
strip -s $CLIBS_PATH/data/bin/*/*

if [ "$OS" == "GNU/Linux" ]; then
CORE_DOC=$CLIBS_PATH
cp -a $INSTALL_PATH/docs $CORE_DOC/data/ || exit 1
rm -rf $CORE_DOC/data/docs/{natron,openfx*} || exit 1
rm -rf $CORE_DOC/data/docs/{libxml,libxslt,ctl,eigen,ftgl,graphviz,imagemagick,opencv,python,tuttleofx,lcms} 
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

if [ "$1" == "workshop" ]; then
cp $CORE_DOC/data/docs/python3/LICENSE $CORE_DOC/meta/python_license.txt || exit 1
cat $CORE_DOC/data/docs/pyside/* > $CORE_DOC/meta/pyside_license.txt || exit 1
cat $CORE_DOC/data/docs/shibroken/* > $CORE_DOC/meta/shiboken_license.txt || exit 1
mv $CORE_DOC/data/docs/shibroken $CORE_DOC/data/docs/shiboken || exit 1
cp $CORE_DOC/data/docs/seexpr/LICENSE $CORE_DOC/meta/seexpr_license.txt || exit 1
else
rm -rf $CORE_DOC/data/docs/{py*,shi*,see*}
fi

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

#if [ "$1" != "workshop" ]; then
TGZ=$TMP_PATH/Natron_${PKGOS}_x86-${BIT}bit_v$NATRON_VERSION
rm -rf $TGZ
mkdir -p $TGZ || exit 1
cp -av $INSTALLER/packages/*/data/* $TGZ/ || exit 1
( cd $TMP_PATH ; tar cvvJf Natron_${PKGOS}_x86-${BIT}bit_v$NATRON_VERSION.txz Natron_${PKGOS}_x86-${BIT}bit_v$NATRON_VERSION)
mv $TGZ.txz $CWD/ || exit 1
#fi

#fi # end linux plugins

chown root:root -R $INSTALLER/*
(cd $INSTALLER; find . -type d -name .git -exec rm -rf {} \;)

echo "Done!"

$INSTALL_PATH/bin/repogen -v --update-new-components -p $INSTALLER/packages -c $INSTALLER/config/config.xml $CWD/repo/$SF_OS/$SF_BRANCH/repo || exit 1

$INSTALL_PATH/bin/binarycreator -v -f -p $INSTALLER/packages -c $INSTALLER/config/config.xml -i fr.inria.natron,fr.inria.corelibs,fr.inria.ocio,net.sf.ofx.io,net.sf.ofx.misc $CWD/Natron_${PKGOS}_install_x86-${BIT}bit_v$NATRON_VERSION || exit 1
tar cvvzf $CWD/Natron_${PKGOS}_install_x86-${BIT}bit_v$NATRON_VERSION.tgz Natron_${PKGOS}_install_x86-${BIT}bit_v$NATRON_VERSION || exit 1

echo "All Done!!! ... test then upload"
