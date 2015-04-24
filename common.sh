#!/bin/sh
# Natron Common Build Options
# Written by Ole-André Rodlie <olear@fxarena.net>

# Versions
#
# Modifying *_PKG also requires modifications to xml's and maybe build-installer.sh

NATRON_STABLE_V=1.2.1
NATRON_PKG=fr.inria.natron
NATRON_STABLE_GIT=77aa4c1c315957ab368d6bdda5b1e3f8b240b9d9
NATRON_DEVEL_GIT=146262d7a27547ea868bffa6ca65eee1ddf739e0

IOPLUG_PKG=fr.inria.openfx.io
IOPLUG_STABLE_GIT=a9b47063061c4930ad67de665f7551e57d41fb7d
IOPLUG_DEVEL_GIT=b8138a3641d934f5e97563208a05e8c0a6ed6f8c

MISCPLUG_PKG=fr.inria.openfx.misc
MISCPLUG_STABLE_GIT=e85add84fbf3e8fd3bdd108936f2a73d2afa80f0
MISCPLUG_DEVEL_GIT=50f467c120be5dbd090dddb3998a01f5b4c9a8fe

ARENAPLUG_PKG=fr.inria.openfx.arena
ARENAPLUG_DEVEL_GIT=8a4a97354ebbaefc92215336a5e9d31ac31d36c0
ARENAPLUG_STABLE_GIT=$ARENAPLUG_DEVEL_GIT

CVPLUG_PKG=fr.inria.openfx.opencv
CVPLUG_DEVEL_GIT=07011b079090bf06be6de358695d3bda4c0407d4
CVPLUG_STABLE_GIT=$CVPLUG_DEVEL_GIT

CORELIBS_PKG=fr.inria.natron.libs
PROFILES_PKG=fr.inria.natron.color

NATRON_INSTALLER_GIT=58806909bbab984757d057ae10b1ad5e14a1dd26

# Override default splash (useful for promo etc)
CUSTOM_SPLASH=1

# SDK
#
# bump minor version (2.0.x) on changes, bump major version (y.0.x) in-sync with natron. Check installer/patches when bumping!

SDK_VERSION=2.0
SDK_PATH=/opt

# Common values
#

CWD=$(pwd)
TMP_PATH=$CWD/tmp
SRC_PATH=$CWD/src
INSTALL_PATH=$SDK_PATH/Natron-$SDK_VERSION

# Keep existing tag, else make a new one
if [ -z "$TAG" ]; then
  TAG=$(date +%Y%m%d%H%M)
fi

OS=$(uname -o)
REPO_DIR=$CWD/repo

# Repo rsync destination url
REPO_DEST=olear@10.10.10.121:/../www/repo.natronvfx.com
REPO_SRC=source

# Third-party sources
#

GIT_OPENCV=https://github.com/devernay/openfx-opencv.git
GIT_ARENA=https://github.com/olear/openfx-arena.git
GIT_INSTALLER=https://github.com/olear/qtifw.git
GIT_NATRON=https://github.com/MrKepzie/Natron.git
GIT_IO=https://github.com/MrKepzie/openfx-io.git
GIT_MISC=https://github.com/devernay/openfx-misc.git
SRC_URL=http://repo.natronvfx.com/source # Where dist files are located
QT4_TAR=qt-everywhere-opensource-src-4.8.6.tar.gz
#QT5_TAR=qt-everywhere-opensource-src-5.4.1.tar.gz # Un-comment and run 'build-sdk.sh qt5' to enable, NOT RECOMMENDED.
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
FFMPEG_TAR=ffmpeg-2.6.2.tar.bz2
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
MAGICK_TAR=ImageMagick-6.8.9-7.tar.bz2
#SSL_TAR=openssl-1.0.0r.tar.gz # needed for https support in installer (currently broken), will not be built if commented out.
JASP_TAR=jasper-1.900.1.zip
DEMOPRO_TAR=Demo_Natronv1.0_by_Francois_Grassard.tar.gz # example project
NATRON_API_DOC=https://media.readthedocs.org/pdf/natron/workshop/natron.pdf # TODO generate own, for now just download latest.

# GCC version
#
# Check for minimal required GCC version

GCC_V=$(gcc --version | awk '/gcc /{print $0;exit 0;}' | awk '{print $3}' | sed 's#\.# #g' | awk '{print $2}')
if [ "$GCC_V" -lt "7" ]; then
  echo "Wrong GCC version. Run installer/scripts/setup-gcc.sh"
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

