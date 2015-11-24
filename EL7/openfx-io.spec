Summary: A set of Readers/Writers plugins written using the OpenFX standard
Name: openfx-io

Version: 20151124
Release: 1%{?dist}
License: GPLv2

Group: System Environment/Base
URL: https://github.com/MrKepzie/openfx-io

Source: %{version}/%{name}-%{version}.tar.xz
Source1: OpenColorIO-1.0.9.tar.gz
Source2: oiio-Release-1.5.20.tar.gz
Source3: lame-3.99.5.tar.gz
Source4: libvpx-1.4.0.tar.bz2
Source5: opus-1.1.tar.gz
Source6: orc-0.4.23.tar.xz
Source7: schroedinger-1.0.11.tar.gz
#Source8: speex-1.2rc1.tar.gz
Source9: x264-snapshot-20150725-2245.tar.bz2
Source10: xvidcore-1.3.4.tar.gz
Source11: SeExpr-rel-1.0.1.tar.gz
Source12: ffmpeg-2.7.2.tar.bz2
Patch1: oiio-exrthreads.patch
Patch2: pre-1.5.21.patch
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

BuildRequires: freetype-devel cmake gcc-c++ mesa-libGL-devel libstdc++-static libpng-devel libjpeg-devel libtiff-devel openjpeg-devel OpenEXR-devel LibRaw-devel boost-devel jasper-devel libtheora-devel libogg-devel zlib-devel bzip2-devel libvorbis-devel yasm

%description
A set of Readers/Writers plugins written using the OpenFX standard.

%prep
%setup
%setup -T -D -a 1
%setup -T -D -a 2
%setup -T -D -a 3
%setup -T -D -a 4
%setup -T -D -a 5
%setup -T -D -a 6
%setup -T -D -a 7
#%setup -T -D -a 8
%setup -T -D -a 9
%setup -T -D -a 10
%setup -T -D -a 11
%setup -T -D -a 12
cd oiio-Release-1.5.20
%patch -P 1 -p1
%patch -P 2 -p1

%build
export IO_TMP=$(pwd)/tmp
export PKG_CONFIG_PATH=$IO_TMP/lib/pkgconfig:$IO_TMP/lib64/pkgconfig
export LD_LIBRARY_PATH=$IO_TMP/lib:$IO_TMP/lib64:$LD_LIBRARY_PATH
export PATH=$IO_TMP/bin:$PATH

# Bundle OCIO (not in base and must be static to work in nuke)
cd OpenColorIO-1.0.9
cmake -DCMAKE_INSTALL_PREFIX=$IO_TMP -DCMAKE_BUILD_TYPE=Release -DOCIO_BUILD_SHARED=OFF -DOCIO_BUILD_STATIC=ON -DOCIO_BUILD_APPS=OFF -DOCIO_BUILD_PYGLUE=OFF
make %{?_smp_mflags} install
cp ext/dist/lib/{liby*.a,libt*.a} $IO_TMP/lib/
sed -i "s/-lOpenColorIO/-lOpenColorIO -lyaml-cpp -ltinyxml -llcms2/" $IO_TMP/lib/pkgconfig/OpenColorIO.pc
cp LICENSE LICENSE.OpenColorIO
cd ..

# Bundle OIIO (not in base and must be static to work in nuke)
cd oiio-Release-1.5.20
CXXFLAGS="-fPIC" cmake -DUSE_OPENCV:BOOL=FALSE -DUSE_OPENSSL:BOOL=FALSE -DUSE_QT:BOOL=FALSE -DUSE_TBB:BOOL=FALSE -DUSE_PYTHON:BOOL=FALSE -DUSE_FIELD3D:BOOL=FALSE -DUSE_OPENJPEG:BOOL=FALSE  -DOIIO_BUILD_TESTS=0 -DOIIO_BUILD_TOOLS=0 -DUSE_LIB_RAW=1 -DCMAKE_INSTALL_PREFIX=$IO_TMP -DSTOP_ON_WARNING:BOOL=FALSE -DUSE_GIF:BOOL=TRUE -DUSE_FREETYPE:BOOL=TRUE -DUSE_FFMPEG:BOOL=FALSE -DLINKSTATIC=0 -DBUILDSTATIC=1
make %{?_smp_mflags} install
cd ..

# Bundle ffmpeg (not in base and must be static to work in nuke)
cd lame-*
CFLAGS="-fPIC" ./configure --prefix=$IO_TMP --libdir=$IO_TMP/lib --disable-shared --enable-static
make %{?_smp_mflags} install
cd ..
cd libvpx-*
./configure --prefix=$IO_TMP --libdir=$IO_TMP/lib --disable-shared --enable-static --enable-vp8 --enable-vp9 --enable-runtime-cpu-detect --enable-postproc --enable-pic --disable-avx --disable-avx2 --disable-examples
make %{?_smp_mflags} install
cd ..
#cd speex-*
#CFLAGS="-fPIC" ./configure --prefix=$IO_TMP --libdir=$IO_TMP/lib --disable-shared --enable-static
#make %{?_smp_mflags} install
#cd ..
cd opus-*
CFLAGS="-fPIC" ./configure --prefix=$IO_TMP --libdir=$IO_TMP/lib --disable-shared --enable-static --enable-custom-modes
make %{?_smp_mflags} install
cd ..
cd orc-*
CFLAGS="-fPIC" ./configure --prefix=$IO_TMP --libdir=$IO_TMP/lib --disable-shared --enable-static
make %{?_smp_mflags} install
cd ..
cd schroedinger-*
CPPFLAGS="-fPIC" ./configure --prefix=$IO_TMP --libdir=$IO_TMP/lib --enable-shared --enable-static
make %{?_smp_mflags} install
rm -f $IO_TMP/lib/libschroe*.so*
sed -i "s/-lschroedinger-1.0/-lschroedinger-1.0 -lorc-0.4/" $IO_TMP/lib/pkgconfig/schroedinger-1.0.pc
cd ..
cd x264*
./configure --prefix=$IO_TMP --libdir=$IO_TMP/lib --enable-shared --enable-static --enable-pic --bit-depth=10
make %{?_smp_mflags} install
rm -f $IO_TMP/*x264*.so*
cd ..
cd xvidcore/build/generic
./configure --prefix=$IO_TMP --libdir=$IO_TMP/lib --enable-shared --enable-static
make
make install
rm -f $IO_TMP/*xvid*.so*
cd ../../..
cd ffmpeg-*
env CPPFLAGS="-I${IO_TMP}/include -fPIC" LDFLAGS="-L${IO_TMP}/lib" ./configure --prefix=$IO_TMP --libdir=$IO_TMP/lib --disable-shared --enable-static --enable-avresample --enable-libmp3lame --enable-libvorbis --enable-libopus --enable-libtheora --enable-libschroedinger --enable-libopenjpeg --disable-libmodplug --enable-libvpx --disable-libspeex --disable-libxcb --disable-libxcb-shm --disable-libxcb-xfixes --disable-indev=jack --disable-outdev=xv --disable-vda --disable-xlib --enable-gpl --enable-libx264 --enable-libxvid --enable-version3
make %{?_smp_mflags} install
cd ..

# Bundle SeExpr (not in base, should probably be a independent pkg, but must be static to work in nuke)
cd SeExpr-*
cmake -DCMAKE_INSTALL_PREFIX=$IO_TMP
make doc
make %{?_smp_mflags} install
rm -f $IO_TMP/lib/*SeExpr*.so*
cd ..

# Build plugins (link static for nuke compat)
# NOTE! since we link against system boost nuke compat will not work
make OIIO_HOME="${IO_TMP}" SEEXPR_HOME="${IO_TMP}" CONFIG=release LDFLAGS_ADD="-static-libgcc -static-libstdc++ -lboost_system -lboost_filesystem -lboost_regex -lboost_thread -lfreetype -lpng -lz -ltiff -ljpeg -lbz2 -ljasper -lraw_r -lopenjpeg"
cp openfx/Support/LICENSE openfx/Support/LICENSE.OpenFX
cp SupportExt/LICENSE SupportExt/LICENSE.SupportExt

%install
mkdir -p %{buildroot}/usr/OFX/Plugins
cp -a IO/Linux-*-release/IO.ofx.bundle %{buildroot}/usr/OFX/Plugins/
strip -s %{buildroot}/usr/OFX/Plugins/*/*/*/*.ofx

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-,root,root,-)
/usr/OFX/Plugins/IO.ofx.bundle
%doc README.md LICENSE openfx/Support/LICENSE.OpenFX SupportExt/LICENSE.SupportExt OpenColorIO-1.0.9/LICENSE.OpenColorIO

%changelog
