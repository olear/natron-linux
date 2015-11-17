Summary: Open source compositing software
Name: Natron

Version: 20151117
Release: 1%{?dist}
License: GPLv2

Group: System Environment/Base
URL: http://natron.fr

Source: %{name}-%{version}.tar.gz
#Source1: cairo-1.14.2.tar.xz
Source2: config.pri
Patch0: global.diff
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

BuildRequires: fontconfig-devel gcc-c++ expat-devel python-pyside-devel shiboken-devel qt-devel boost-devel pixman-devel glew-devel cairo-devel
Requires: fontconfig qt-x11 python-pyside shiboken-libs boost-serialization pixman glew cairo

%description
Open source compositing software. Node-graph based. Similar in functionalities to Adobe After Effects and Nuke by The Foundry.

%package -n NatronRenderer
Summary: Natron CLI Renderer
%description -n NatronRenderer
Natron CLI Renderer

%prep
%setup
#%setup -T -D -a 1
%patch0 -p0

%build
export NATRON_TMP=$(pwd)/tmp
export PKG_CONFIG_PATH=$NATRON_TMP/lib/pkgconfig
export LD_LIBRARY_PATH=$NATRON_TMP/lib:$LD_LIBRARY_PATH
export PATH=$NATRON_TMP/bin:$PATH

# Build cairo
#cd cairo-1.14.2
#./configure --prefix=$NATRON_TMP --enable-static --disable-shared
#make %{?_smp_mflags} install
#cp COPYING-MPL-1.1 LICENSE.cairo
#cd ..

# Build natron
cp %{SOURCE2} config.pri
mkdir build
cd build
qmake-qt4 -r ../Project.pro CONFIG+=release DEFINES+=QT_NO_DEBUG_OUTPUT
make %{?_smp_mflags}

%install
mkdir -p %{buildroot}/usr/bin %{buildroot}/usr/share/{applications,pixmaps}
cp tools/linux/include/natron/Natron2.desktop %{buildroot}/usr/share/applications/Natron.desktop
cp Gui/Resources/Images/natronIcon256_linux.png %{buildroot}/usr/share/pixmaps/Natron.png
cp build/App/Natron %{buildroot}/usr/bin/
cp build/Renderer/NatronRenderer %{buildroot}/usr/bin/

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-,root,root,-)
/usr/bin/Natron
/usr/share/applications/Natron.desktop
/usr/share/pixmaps/Natron.png
%doc LICENSE.txt
# cairo-1.14.2/LICENSE.cairo

%files -n NatronRenderer
%defattr(-,root,root,-)
/usr/bin/NatronRenderer
%doc LICENSE.txt
# cairo-1.14.2/LICENSE.cairo

%changelog
