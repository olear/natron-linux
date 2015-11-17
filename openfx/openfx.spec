Summary: OpenFX effects API 
Name: openfx

Version: 20151117
Release: 1%{?dist}
License: BSD

Group: System Environment/Base
URL: https://github.com/devernay/openfx

Source: %{version}/%{name}-%{version}.tar.gz
Patch0: libofxHost.diff
Patch1: libofxSupport.diff
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

BuildRequires: gcc-c++ expat-devel pkgconfig
Requires: expat

%description
A fork from the official openfx repository with bug fixes and enhancements.

%package devel
Summary: OpenFX includes
%description devel
OpenFX includes

%prep
%setup
%patch0 -p0
%patch1 -p0

%build
cd Support/Library
make
cd ../../HostSupport
make

%install
mkdir -p %{buildroot}%{_libdir} %{buildroot}%{_includedir}/openfx
cp Support/Library/libofxSupport.so %{buildroot}%{_libdir}
cp HostSupport/Linux-release/libofxHost.so %{buildroot}%{_libdir}
cp -a Support/include/* %{buildroot}%{_includedir}/openfx/
cp -a HostSupport/include/* %{buildroot}%{_includedir}/openfx/
cp -a include/* %{buildroot}%{_includedir}/openfx/

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-,root,root,-)
%{_libdir}/libofxHost.so
%{_libdir}/libofxSupport.so
%doc Support/LICENSE CHANGES

%files devel
%defattr(-,root,root,-)
%{_includedir}/openfx

%changelog
* Thu Nov 17 2015 Ole-André Rodlie <olear@dracolinux.org> - 20151117-1
- Initial RPM release

