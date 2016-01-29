Summary: Miscellaneous OFX / OpenFX / Open Effects plugins
Name: openfx-misc

Version: 20160129
Release: 1%{?dist}
License: GPLv2

Group: System Environment/Base
URL: https://github.com/devernay/openfx-misc

Source: %{version}/%{name}-%{version}.tar.xz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

BuildRequires: gcc-c++ mesa-libGL-devel libstdc++-static
Requires: mesa-libGL

%description
Miscellaneous OFX / OpenFX / Open Effects plugins.

%package -n openfx-cimg
Summary: Miscellaneous OpenFX plugins using CImg
%description -n openfx-cimg
Miscellaneous OpenFX plugins using CImg

%prep
%setup

%build
make -C CImg CImg.h
make -C CImg CONFIG=release CXXFLAGS_ADD="-fopenmp" LDFLAGS_ADD="-fopenmp -static-libgcc -static-libstdc++" %{?_smp_mflags}
make CONFIG=release LDFLAGS_ADD="-static-libgcc -static-libstdc++"
cp openfx/Support/LICENSE openfx/Support/LICENSE.OpenFX
cp SupportExt/LICENSE SupportExt/LICENSE.SupportExt

%install
mkdir -p %{buildroot}/usr/OFX/Plugins
cp -a {Misc,CImg}/Linux-*-release/*.ofx.bundle %{buildroot}/usr/OFX/Plugins/
strip -s %{buildroot}/usr/OFX/Plugins/*/*/*/*.ofx

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-,root,root,-)
/usr/OFX/Plugins/Misc.ofx.bundle
%doc LICENSE openfx/Support/LICENSE.OpenFX SupportExt/LICENSE.SupportExt

%files -n openfx-cimg
%defattr(-,root,root,-)
/usr/OFX/Plugins/CImg.ofx.bundle
%doc LICENSE openfx/Support/LICENSE.OpenFX SupportExt/LICENSE.SupportExt

%changelog
