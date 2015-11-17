Name:           shiboken
Version:        1.2.2
Release:        2%{?dist}
Summary:        CPython bindings generator for C++ libraries

Group:          Development/Tools
License:        GPLv2
URL:            http://www.pyside.org
Source0:        http://download.qt-project.org/official_releases/pyside/shiboken-%{version}.tar.bz2

#BuildRequires:  apiextractor-devel
BuildRequires:  cmake
#BuildRequires:  generatorrunner-devel
BuildRequires:  python2-devel
BuildRequires:  python-sphinx
BuildRequires:  qt4-devel
BuildRequires:  sparsehash-devel

Requires:       %{name}-libs%{?_isa} = %{version}-%{release}
# for %%{_libdir}/generatorrunner/
#Requires:       generatorrunner

%description
Shiboken is a bindings generator for C++ libraries that outputs CPython
source code. It uses generatorrunner and apiextractor to collect information
from library headers, merging modifications and handwritten code defined in the
type system description.

Shiboken is the binding generator used to create the PySide bindings.


%package        libs
Summary:        CPython bindings generator for C++ libraries - shared library
Group:          System Environment/Libraries
License:        LGPLv2 with exceptions

%description    libs
Shiboken is a bindings generator for C++ libraries that outputs CPython
source code. It uses generatorrunner and apiextractor to collect information
from library headers, merging modifications and handwritten code defined in the
type system description.

This is the shared library used by shiboken.


%package        devel
Summary:        Development files for %{name}
Group:          Development/Libraries
License:        GPLv2 and LGPLv2 with exceptions
Requires:       %{name} = %{version}-%{release}
Requires:       %{name}-libs%{?_isa} = %{version}-%{release}
Requires:       cmake
Requires:       python2-devel

%description    devel
The %{name}-devel package contains libraries and header files for
developing applications that use %{name}.


%prep
%setup -q

# Build against sparsehash package
rm -rf ext/sparsehash/


%build
mkdir -p %{_target_platform}
pushd %{_target_platform}
%{cmake} ..
popd

make %{?_smp_mflags} -C %{_target_platform}

# Build html docs
make %{?_smp_mflags} -C %{_target_platform} doc
rm -f %{_target_platform}/doc/html/_static/images/._*
rm -f %{_target_platform}/doc/html/.buildinfo
rm -f %{_target_platform}/doc/html/objects.inv
rm -rf %{_target_platform}/doc/html/.doctrees


%install
make install DESTDIR=$RPM_BUILD_ROOT -C %{_target_platform}


%check
make test -C %{_target_platform}


%post libs -p /sbin/ldconfig

%postun libs -p /sbin/ldconfig


%files
%doc ChangeLog COPYING
%{_bindir}/shiboken
%{_mandir}/man1/shiboken.1*

%files libs
%doc COPYING.libshiboken
%{_libdir}/libshiboken*.so.1.2*
%{python_sitearch}/shiboken.so

%files devel
%doc %{_target_platform}/doc/html/
%{_includedir}/shiboken/
%{_libdir}/libshiboken*.so
%{_libdir}/pkgconfig/shiboken.pc
%{_libdir}/cmake/Shiboken-%{version}/


%changelog
* Mon Aug 18 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.2.2-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_21_22_Mass_Rebuild

* Mon Jun 09 2014 Jaroslav Reznik <jreznik@redhat.com> - 1.2.2-1
- Update to 1.2.2

* Sun Jun 08 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.2.1-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_21_Mass_Rebuild

* Tue Sep 03 2013 Rex Dieter <rdieter@fedoraproject.org> 1.2.1-1
- 1.2.1

* Sun Aug 04 2013 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.1.0-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_20_Mass_Rebuild

* Thu Feb 14 2013 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.1.0-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_19_Mass_Rebuild

* Fri Jul 27 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.1.0-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_18_Mass_Rebuild

* Sat Jan 21 2012 Kalev Lember <kalevlember@gmail.com> - 1.1.0-1
- Update to 1.1.0

* Sat Jan 14 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.0.9-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_17_Mass_Rebuild

* Wed Oct 26 2011 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.0.9-2
- Rebuilt for glibc bug#747377

* Fri Oct 21 2011 Kalev Lember <kalevlember@gmail.com> - 1.0.9-1
- Update to 1.0.9

* Thu Aug 25 2011 Kalev Lember <kalevlember@gmail.com> - 1.0.6-1
- Update to 1.0.6

* Thu Jun 23 2011 Kalev Lember <kalev@smartlink.ee> - 1.0.4-1
- Update to 1.0.4
- Cleaned up the spec file for modern rpmbuild

* Fri May 27 2011 Kalev Lember <kalev@smartlink.ee> - 1.0.3-1
- Update to 1.0.3

* Sun May 01 2011 Kalev Lember <kalev@smartlink.ee> - 1.0.2-1
- Update to 1.0.2

* Sun Apr 03 2011 Kalev Lember <kalev@smartlink.ee> - 1.0.1-1
- Update to 1.0.1

* Thu Mar 03 2011 Kalev Lember <kalev@smartlink.ee> - 1.0.0-1
- Update to 1.0.0

* Wed Feb 09 2011 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.0.0-0.4.beta4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_15_Mass_Rebuild

* Sat Jan 22 2011 Kalev Lember <kalev@smartlink.ee> - 1.0.0-0.3.beta4
- Update to 1.0.0~beta4

* Sat Nov 27 2010 Kalev Lember <kalev@smartlink.ee> - 1.0.0-0.2.beta1
- Removed spurious objects.inv file from html docs

* Fri Nov 26 2010 Kalev Lember <kalev@smartlink.ee> - 1.0.0-0.1.beta1
- Update to 1.0.0~beta1

* Thu Oct 14 2010 Kalev Lember <kalev@smartlink.ee> - 0.5.1-1
- Update to 0.5.1
- Dropped upstreamed pkgconfig patch

* Wed Sep 29 2010 jkeating - 0.5.0-3
- Rebuilt for gcc bug 634757

* Sat Sep 11 2010 Kalev Lember <kalev@smartlink.ee> - 0.5.0-2
- Added patch to fix pkgconfig file generation

* Sat Sep 11 2010 Kalev Lember <kalev@smartlink.ee> - 0.5.0-1
- Update to 0.5.0
- Dropped upstreamed patches

* Wed Aug 04 2010 Kalev Lember <kalev@smartlink.ee> - 0.4.0-1
- Update to 0.4.0
- Backport patch to fix tests with Python 2.7

* Mon Aug 02 2010 Kalev Lember <kalev@smartlink.ee> - 0.3.2-6
- Temporarily disable tests to fix build with Python 2.7

* Sat Jul 31 2010 Orcan Ogetbil <oget[dot]fedora[at]gmail[dot]com> - 0.3.2-5
- Rebuilt for https://fedoraproject.org/wiki/Features/Python_2.7/MassRebuild

* Sat Jul 24 2010 Kalev Lember <kalev@smartlink.ee> - 0.3.2-4
- Explicitly require generatorrunner for %%{_libdir}/generatorrunner/ directory
  ownership (#609738)

* Sat Jul 24 2010 Kalev Lember <kalev@smartlink.ee> - 0.3.2-3
- Require python2-devel in devel package as the public headers include Python.h

* Sat Jul 24 2010 Kalev Lember <kalev@smartlink.ee> - 0.3.2-2
- BR sparsehash-devel instead of sparsehash (#609738)

* Thu Jul 01 2010 Kalev Lember <kalev@smartlink.ee> - 0.3.2-1
- Initial RPM release
