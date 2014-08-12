#!/bin/sh
#
# Written by Ole Andre Rodlie <olear@dracolinux.org>
#

NATRON_VERSION=20140812.1
SDK_VERSION=1.0
SNAPSHOT=20140729

SF_PROJECT=dracolinux
SF_REPO=natron
SF_BRANCH=workshop

DATE=$(date +%Y-%m-%d)
DATE_NUM=$(echo $DATE | sed 's/-//g')

# Arch
if [ -z "$ARCH" ]; then
  case "$( uname -m )" in
    i?86) export ARCH=i686 ;;
       *) export ARCH=$( uname -m ) ;;
  esac
fi
if [ "$ARCH" = "i686" ]; then
  BIT=32
elif [ "$ARCH" = "x86_64" ]; then
  BIT=64
fi

SF_OS=linux$BIT
CWD=$(pwd)
INSTALL_PATH=/opt/Natron-$SDK_VERSION
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

mkdir -p $INSTALLER/{config,packages} || exit 1
cat $CWD/installer/config/config.xml | sed "s/_VERSION_/${NATRON_VERSION}/;s/_PROJECT_/${SF_PROJECT}/g;s/_REPO_/${SF_REPO}/g;s/_OS_/${SF_OS}/g;s/_BRANCH_/${SF_BRANCH}/g" > $INSTALLER/config/config.xml || exit 1
cp $CWD/installer/config/*.png $INSTALLER/config/ || exit 1

# OFX IO
OFX_IO_VERSION=$NATRON_VERSION
OFX_IO_PATH=$INSTALLER/packages/net.sf.ofx.io
mkdir -p $OFX_IO_PATH/{data,meta} $OFX_IO_PATH/data/Plugins $OFX_IO_PATH/data/docs/openfx-io || exit 1
cat $XML/openfx-io.xml | sed "s/_VERSION_/${OFX_IO_VERSION}/;s/_DATE_/${DATE}/" > $OFX_IO_PATH/meta/package.xml || exit 1
cat $QS/openfx-io.qs > $OFX_IO_PATH/meta/installscript.qs || exit 1
cp -a $INSTALL_PATH/docs/openfx-io $OFX_IO_PATH/data/docs/ || exit 1
cat $OFX_IO_PATH/data/docs/openfx-io/LICENSE > $OFX_IO_PATH/meta/license.txt || exit 1
cp -a $INSTALL_PATH/Plugins/IO.ofx.bundle $OFX_IO_PATH/data/Plugins/ || exit 1
strip -s $OFX_IO_PATH/data/Plugins/*/*/*/*

# OFX MISC
OFX_MISC_VERSION=$NATRON_VERSION
OFX_MISC_PATH=$INSTALLER/packages/net.sf.ofx.misc
mkdir -p $OFX_MISC_PATH/{data,meta} $OFX_MISC_PATH/data/Plugins $OFX_MISC_PATH/data/docs/openfx-misc || exit 1
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
cat $QS/workshop.qs > $NATRON_PATH/meta/installscript.qs || exit 1
cp -a $INSTALL_PATH/docs/natron $NATRON_PATH/data/docs/ || exit 1
cat $NATRON_PATH/data/docs/natron/LICENSE.txt > $NATRON_PATH/meta/license.txt || exit 1
cp $INSTALL_PATH/bin/Natron $INSTALL_PATH/bin/NatronRenderer $INSTALL_PATH/bin/Natron.debug $NATRON_PATH/data/bin/ || exit 1
strip -s $NATRON_PATH/data/bin/*
cat $CWD/installer/Natron.sh > $NATRON_PATH/data/Natron || exit 1
cat $CWD/installer/Natron.sh | sed "s#bin/Natron#bin/NatronRenderer#" > $NATRON_PATH/data/NatronRenderer || exit 1
cat $CWD/installer/Natron-portable.sh > $NATRON_PATH/data/Natron-portable || exit 1
cat $CWD/installer/Natron-portable.sh | sed "s#bin/Natron#bin/NatronRenderer#" > $NATRON_PATH/data/NatronRenderer-portable || exit 1

chmod +x $NATRON_PATH/data/{Natron,Natron-portable} $NATRON_PATH/data/{NatronRenderer,NatronRenderer-portable} || exit 1

# OCIO
OCIO_VERSION=$NATRON_VERSION
OCIO_PATH=$INSTALLER/packages/fr.inria.ocio
mkdir -p $OCIO_PATH/meta $OCIO_PATH/data/share || exit 1
cat $XML/ocio.xml | sed "s/_VERSION_/${OCIO_VERSION}/;s/_DATE_/${DATE}/" > $OCIO_PATH/meta/package.xml || exit 1
cat $QS/ocio.qs > $OCIO_PATH/meta/installscript.qs || exit 1
cp -a $INSTALL_PATH/share/OpenColorIO-Configs $OCIO_PATH/data/share/ || exit 1

# CORE LIBS
CLIBS_VERSION=$SDK_VERSION
CLIBS_PATH=$INSTALLER/packages/fr.inria.corelibs
mkdir -p $CLIBS_PATH/meta $CLIBS_PATH/data/{bin,lib} $CLIBS_PATH/data/share/pixmaps || exit 1
cat $XML/corelibs.xml | sed "s/_VERSION_/${CLIBS_VERSION}/;s/_DATE_/${DATE}/" > $CLIBS_PATH/meta/package.xml || exit 1
cat $QS/corelibs.qs > $CLIBS_PATH/meta/installscript.qs || exit 1

cp $INSTALL_PATH/share/pixmaps/natronIcon256_linux.png $CLIBS_PATH/data/share/pixmaps/ || exit 1
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

strip -s $CLIBS_PATH/data/lib/*
strip -s $CLIBS_PATH/data/bin/*/*

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

chown root:root -R $INSTALLER/*
(cd $INSTALLER; find . -type d -name .git -exec rm -rf {} \;)

if [ ! -d $CWD/repo/linux${BIT}/$SF_BRANCH ]; then
  mkdir -p $CWD/repo/linux${BIT}/$SF_BRANCH || exit 1
fi

echo "Done!"
$INSTALL_PATH/bin/binarycreator -v -f -p $INSTALLER/packages -c $INSTALLER/config/config.xml -i fr.inria.natron,fr.inria.corelibs,fr.inria.ocio,net.sf.ofx.io,net.sf.ofx.misc $CWD/Natron_Linux_workshop_install_x86-${BIT}bit_v$NATRON_VERSION || exit 1
tar cvvzf repo/linux${BIT}/$SF_BRANCH/Natron_Linux_workshop_install_x86-${BIT}bit_v$NATRON_VERSION.tgz Natron_Linux_workshop_install_x86-${BIT}bit_v$NATRON_VERSION || exit 1

