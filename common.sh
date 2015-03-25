#!/bin/sh

# Versions
NATRON_STABLE_GIT=77aa4c1c315957ab368d6bdda5b1e3f8b240b9d9
NATRON_DEVEL_GIT=d28238e3a4147f1865f554d6722569b6840245df

IOPLUG_STABLE_GIT=a9b47063061c4930ad67de665f7551e57d41fb7d
IOPLUG_DEVEL_GIT=4c2b42437d52b04b8d01f58eabfb14faef8a9746

MISCPLUG_STABLE_GIT=e85add84fbf3e8fd3bdd108936f2a73d2afa80f0
MISCPLUG_DEVEL_GIT=3de236c5431e24552aef329674a2294ff5ffda86

# SDK
SDK_VERSION=2.0
SDK_PATH=/opt

# Common
CWD=$(pwd)
TMP_PATH=$CWD/tmp
SRC_PATH=$CWD/src
INSTALL_PATH=$SDK_PATH/Natron-$SDK_VERSION
TAG=$(date +%Y%m%d%H%M)
OS=$(uname -o)

# Dist
GIT_NATRON=https://github.com/MrKepzie/Natron.git
GIT_IO=https://github.com/MrKepzie/openfx-io.git
GIT_MISC=https://github.com/devernay/openfx-misc.git
SRC_URL=http://repo.natronvfx.com/source
QT4_TAR=qt-everywhere-opensource-src-4.8.6.tar.gz
#QT5_TAR=qt-everywhere-opensource-src-5.4.1.tar.gz
QIFW_TAR=installer-framework-installer-framework-f586369bd5b0a876a148c203b0243a8378b45482.tar.gz
YASM_TAR=yasm-1.2.0.tar.gz
CMAKE_TAR=cmake-2.8.12.2.tar.gz
PY_TAR=Python-2.7.9.tar.xz
JPG_TAR=jpegsrc.v9a.tar.gz
OJPG_TAR=openjpeg-1.5.1.tar.gz
PNG_TAR=libpng-1.2.52.tar.xz
TIF_TAR=tiff-4.0.3.tar.gz
ILM_TAR=ilmbase-2.2.0.tar.gz
EXR_TAR=openexr-2.2.0.tar.gz
GLEW_TAR=glew-1.12.0.tgz
BOOST_TAR=boost_1_57_0.tar.bz2
CAIRO_TAR=cairo-1.14.2.tar.xz
FFMPEG_TAR=ffmpeg-2.4.7.tar.bz2
OCIO_TAR=OpenColorIO-1.0.9.tar.gz
OIIO_TAR=oiio-Release-1.4.16.tar.gz
PYSIDE_TAR=pyside-qt4.8+1.2.2.tar.bz2 
PY3_TAR=Python-3.4.3.tar.xz   
SHIBOK_TAR=shiboken-1.2.2.tar.bz2  
LIBXML_TAR=libxml2-2.9.2.tar.gz
LIBXSL_TAR=libxslt-1.1.28.tar.gz
SEE_TAR=SeExpr-rel-1.0.1.tar.gz
LIBRAW_TAR=LibRaw-0.16.0.tar.gz
PIX_TAR=pixman-0.32.6.tar.gz
LCMS_TAR=lcms2-2.6.tar.gz
#SSL_TAR=openssl-1.0.0r.tar.gz
JASP_TAR=jasper-1.900.1.zip

# GCC version
GCC_V=$(gcc --version | awk '/gcc /{print $0;exit 0;}' | awk '{print $3}' | sed 's#\.# #g' | awk '{print $2}')
if [ "$GCC_V" -lt "7" ]; then
  echo "Wrong GCC version. Run installer/scripts/setup-gcc.sh"
  exit 1
fi

# Linux version
RHEL_MAJOR=$(cat /etc/redhat-release | cut -d" " -f3 | cut -d "." -f1)
RHEL_MINOR=$(cat /etc/redhat-release | cut -d" " -f3 | cut -d "." -f2)
if [ ! -f /etc/redhat-release ]; then
  echo "Wrong distro, stupid :P"
  exit 1
else
  if [ "$RHEL_MAJOR" != "6" ] && [ "$RHEL_MINOR" != "2" ]; then
    echo "Wrong distro version, 6.2 only at the moment!"
    exit 1
  fi
fi

# Arch
if [ -z "$ARCH" ]; then
  case "$( uname -m )" in
    i?86) export ARCH=i686 ;;
       *) export ARCH=$( uname -m ) ;;
  esac
fi
if [ "$ARCH" = "i686" ]; then
  BF="-O2 -march=i686 -mtune=i686"
  BIT=32
elif [ "$ARCH" = "x86_64" ]; then
  BF="-O2 -fPIC"
  BIT=64
else
  BF="-O2"
fi

# Threads
if [ -z "$MKJOBS" ]; then
  MKJOBS=4
fi

if [ ! -d $SRC_PATH ]; then
  mkdir -p $SRC_PATH || exit 1
fi

