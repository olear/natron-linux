#!/bin/sh
# Natron Common Build Options
# Written by Ole-André Rodlie <olear@fxarena.net>

# Versions
#

NATRON_STABLE_V=2.0
NATRON_PKG=fr.inria.natron
NATRON_STABLE_GIT=#
NATRON_DEVEL_GIT=27d8dfe0b7c7bd4be2d4e4dc4e71c5e186b47250

IOPLUG_PKG=fr.inria.openfx.io
IOPLUG_STABLE_GIT=#
IOPLUG_DEVEL_GIT=be40a65c408346fb409239745fdb35e7d47aa761

MISCPLUG_PKG=fr.inria.openfx.misc
MISCPLUG_STABLE_GIT=#
MISCPLUG_DEVEL_GIT=ac5c0168ad7d2ee80c7bc4c217fb589b33a0a8e1

ARENAPLUG_PKG=fr.inria.openfx.extra
ARENAPLUG_STABLE_GIT=#
ARENAPLUG_DEVEL_GIT=f2800150f41a73086dd72d5bdb2d7fd330d78141

CVPLUG_PKG=fr.inria.openfx.opencv
CVPLUG_DEVEL_GIT=c46145254e85f9eb236d361b58885107ce4cb653
CVPLUG_STABLE_GIT=#

CORELIBS_PKG=fr.inria.natron.libs
PROFILES_PKG=fr.inria.natron.color
PROFILES_VERSION=2.0

NATRON_INSTALLER_GIT=58806909bbab984757d057ae10b1ad5e14a1dd26

# Repo settings
#

REPO_DEST=olear@10.10.10.121:../www/repo.natronvfx.com
REPO_SRC=source
REPO_URL=http://repo.natronvfx.com
SRC_URL=http://repo.natronvfx.com/source

# SDK
#

SDK_VERSION=2.0
SDK_PATH=/opt

# Common values
#

CWD=$(pwd)
TMP_PATH=$CWD/tmp
SRC_PATH=$CWD/src
INSTALL_PATH=$SDK_PATH/Natron-$SDK_VERSION
INC_PATH=$CWD/installer2

# Keep existing tag, else make a new one
if [ -z "$TAG" ]; then
  TAG=$(date +%Y%m%d%H%M)
fi

OS=$(uname -o)
REPO_DIR=$CWD/repo

# Third-party sources
#

GIT_OPENCV=https://github.com/devernay/openfx-opencv.git
GIT_ARENA=https://github.com/olear/openfx-arena.git
GIT_INSTALLER=https://github.com/olear/qtifw.git
GIT_NATRON=https://github.com/MrKepzie/Natron.git
GIT_IO=https://github.com/MrKepzie/openfx-io.git
GIT_MISC=https://github.com/devernay/openfx-misc.git
SRC_URL=http://repo.natronvfx.com/source 
QT4_TAR=qt-everywhere-opensource-src-4.8.7.tar.gz
#QT5_TAR=qt-everywhere-opensource-src-5.4.1.tar.gz
CV_TAR=opencv-2.4.10.zip
EIGEN_TAR=eigen-eigen-b23437e61a07.tar.bz2
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
FFMPEG_TAR=ffmpeg-2.7.1.tar.gz
OCIO_TAR=OpenColorIO-1.0.9.tar.gz
OIIO_TAR=oiio-Release-1.5.15.tar.gz
PYSIDE_TAR=pyside-qt4.8+1.2.2.tar.bz2 
PY3_TAR=Python-3.4.3.tar.xz   
SHIBOK_TAR=shiboken-1.2.2.tar.bz2  
LIBXML_TAR=libxml2-2.9.2.tar.gz
LIBXSL_TAR=libxslt-1.1.28.tar.gz
SEE_TAR=SeExpr-rel-1.0.1.tar.gz
LIBRAW_TAR=LibRaw-0.16.0.tar.gz
PIX_TAR=pixman-0.32.6.tar.gz
LCMS_TAR=lcms2-2.6.tar.gz
MAGICK_TAR=ImageMagick-6.8.9-10.tar.gz
#SSL_TAR=openssl-1.0.0r.tar.gz 
JASP_TAR=jasper-1.900.1.zip
NATRON_API_DOC=https://media.readthedocs.org/pdf/natron/workshop/natron.pdf # TODO generate own

# GCC version
#
# Check for minimal required GCC version

GCC_V=$(gcc --version | awk '/gcc /{print $0;exit 0;}' | awk '{print $3}' | sed 's#\.# #g' | awk '{print $2}')
if [ "$GCC_V" -lt "7" ]; then
  echo "Wrong GCC version. Run ${INC_PATH}/scripts/setup-gcc.sh"
  exit 1
fi

# Linux version
#
# Check distro and version. CentOS/RHEL 6.2 only!

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
#
# Default build flags

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
#
# Set build threads to 4 if not exists

if [ -z "$MKJOBS" ]; then
  MKJOBS=4
fi

# Directories
#
# Make source dir if not exists

if [ ! -d $SRC_PATH ]; then
  mkdir -p $SRC_PATH || exit 1
fi

