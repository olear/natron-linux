Summary: Open source compositing software
Name: Natron

Version: 20151124
Release: 1%{?dist}
License: GPLv2

Group: System Environment/Base
URL: http://natron.fr

Source: %{name}-%{version}.tar.xz
Source2: config.pri
Patch1: global.diff
Patch2: fc-nowarn.diff
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

BuildRequires: fontconfig-devel gcc-c++ expat-devel python-pyside-devel shiboken-devel qt-devel boost-devel pixman-devel glew-devel cairo-devel
Requires: fontconfig qt-x11 python-pyside shiboken-libs boost-serialization pixman glew cairo OpenColorIO-Configs

%description
Open source compositing software. Node-graph based. Similar in functionalities to Adobe After Effects and Nuke by The Foundry.

%package -n NatronRenderer
Summary: Natron CLI Renderer
Requires: OpenColorIO-Configs
%description -n NatronRenderer
Natron CLI Renderer

%prep
%setup
%patch -P 1 -p0
%patch -P 2 -p0

%build
export NATRON_TMP=$(pwd)/tmp
export PKG_CONFIG_PATH=$NATRON_TMP/lib/pkgconfig
export LD_LIBRARY_PATH=$NATRON_TMP/lib:$LD_LIBRARY_PATH
export PATH=$NATRON_TMP/bin:$PATH

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

%files -n NatronRenderer
%defattr(-,root,root,-)
/usr/bin/NatronRenderer
%doc LICENSE.txt

%changelog
