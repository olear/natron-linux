%global runtests 1

Name:           python-pyside
Version:        1.2.2
Release:        4%{?dist}
Summary:        Python bindings for Qt4

License:        LGPLv2
URL:            http://www.pyside.org
Source0:        http://download.qt-project.org/official_releases/pyside/pyside-qt4.8+%{version}.tar.bz2

BuildRequires:  cmake
#BuildRequires:  generatorrunner-devel
BuildRequires:  phonon-devel
BuildRequires:  python2-devel
BuildRequires:  qt4-devel
BuildRequires:  qt4-webkit-devel
BuildRequires:  shiboken-devel >= 1.2.0
BuildRequires:  xorg-x11-server-Xvfb
BuildRequires:  xorg-x11-xauth

%{?_qt4_version:Requires: qt4%{?_isa} >= %{_qt4_version}}

# Don't want provides for python shared objects
%{?filter_provides_in: %filter_provides_in %{python_sitearch}/PySide/.*\.so}
%{?filter_setup}

%description
PySide provides Python bindings for the Qt cross-platform application
and UI framework. PySide consists of a full set of Qt bindings, being
compatible with PyQt4 API 2.


%package        devel
Summary:        Development files for %{name}
Requires:       %{name}%{?_isa} = %{version}-%{release}
Requires:       cmake
Requires:       phonon-devel
Requires:       python2-devel
Requires:       qt4-devel
Requires:       qt4-webkit-devel
Requires:       shiboken-devel

%description    devel
The %{name}-devel package contains libraries and header files for
developing applications that use %{name}.


%prep
%setup -q -n pyside-qt4.8+%{version}

# Fix up unit tests to use lrelease-qt4
sed -i -e "s/lrelease /lrelease-qt4 /" tests/QtCore/translation_test.py


%build
mkdir -p %{_target_platform}
pushd %{_target_platform}
%{cmake} -DCMAKE_BUILD_TYPE=Release ..
popd

make %{?_smp_mflags} -C %{_target_platform}


%install
make install DESTDIR=$RPM_BUILD_ROOT -C %{_target_platform}

# Fix permissions
chmod 755 $RPM_BUILD_ROOT%{python_sitearch}/PySide/*.so


%check
%if 0%{?runtests}
# Tests need an X server
export DISPLAY=:21
Xvfb $DISPLAY &
trap "kill $! ||:" EXIT
sleep 3

pushd %{_target_platform}
ctest -V ||:
popd
%endif


%post -p /sbin/ldconfig
%postun -p /sbin/ldconfig

%files
%doc COPYING PySide/licensecomment.txt
%{_libdir}/libpyside*.so.*
%{python_sitearch}/PySide/

%files devel
%{_includedir}/PySide/
%{_libdir}/libpyside*.so
%{_libdir}/cmake/PySide-%{version}/
%{_libdir}/pkgconfig/pyside.pc
%{_datadir}/PySide/


%changelog
* Thu Jun 18 2015 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.2.2-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_23_Mass_Rebuild

* Sat May 02 2015 Kalev Lember <kalevlember@gmail.com> - 1.2.2-3
- Rebuilt for GCC 5 C++11 ABI change

* Sun Aug 17 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.2.2-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_21_22_Mass_Rebuild

* Mon Jun 09 2014 Jaroslav Reznik <jreznik@redhat.com> 1.2.2-1
- 1.2.2

* Sat Jun 07 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.2.1-2
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

* Sat Jan 14 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.0.8-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_17_Mass_Rebuild

* Wed Oct 26 2011 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.0.8-2
- Rebuilt for glibc bug#747377

* Fri Oct 21 2011 Kalev Lember <kalevlember@gmail.com> - 1.0.8-1
- Update to 1.0.8
- Dropped the Qt 4.8 patch that was merged upstream

* Thu Aug 25 2011 Kalev Lember <kalevlember@gmail.com> - 1.0.6-1
- Update to 1.0.6
- Added a patch for building with Qt 4.8

* Thu Jun 23 2011 Kalev Lember <kalev@smartlink.ee> - 1.0.4-1
- Update to 1.0.4
- Cleaned up the spec file for modern rpmbuild

* Fri May 27 2011 Kalev Lember <kalev@smartlink.ee> - 1.0.3-1
- Update to 1.0.3

* Sun May 01 2011 Kalev Lember <kalev@smartlink.ee> - 1.0.2-1
- Update to 1.0.2

* Sun Apr 03 2011 Kalev Lember <kalev@smartlink.ee> - 1.0.1-1
- Update to 1.0.1

* Thu Mar 03 2011 Kalev Lember <kalev@smartlink.ee> - 1.0.0-1.1
- Require Qt version greater or equal than the package was built with

* Thu Mar 03 2011 Kalev Lember <kalev@smartlink.ee> - 1.0.0-1
- Update to 1.0.0
- Re-enabled Provides filtering
- Force Release build type to make sure NDEBUG is defined

* Wed Feb 09 2011 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.0.0-0.3.beta4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_15_Mass_Rebuild

* Sat Jan 22 2011 Kalev Lember <kalev@smartlink.ee> - 1.0.0-0.2.beta4
- Update to 1.0.0~beta4
- Dropped upstreamed patches
- Disabled Provides filtering which fails with ~ in directory name

* Fri Nov 26 2010 Kalev Lember <kalev@smartlink.ee> - 1.0.0-0.1.beta1
- Update to 1.0.0~beta1
- Patch phonon bindings to build with phonon 4.4.3

* Thu Oct 14 2010 Kalev Lember <kalev@smartlink.ee> - 0.4.2-1
- Update to 0.4.2
- Dropped upstreamed patches

* Sat Oct 02 2010 Kalev Lember <kalev@smartlink.ee> - 0.4.1-4
- Re-enabled phonon bindings

* Wed Sep 29 2010 jkeating - 0.4.1-3
- Rebuilt for gcc bug 634757

* Fri Sep 17 2010 Kalev Lember <kalev@smartlink.ee> - 0.4.1-2
- Depend on qt4-webkit-devel instead of qt-webkit-devel

* Sat Sep 11 2010 Kalev Lember <kalev@smartlink.ee> - 0.4.1-1
- Update to 0.4.1
- Added patch to disable xvfb-run which is currently broken (#632879)
- Disabled phonon bindings (PySide bug #355)
- License change from LGPLv2 with exceptions to LGPLv2

* Sun Aug 15 2010 Kalev Lember <kalev@smartlink.ee> - 0.4.0-3
- Review related fixes (#623425)
- Include PySide/licensecomment.txt

* Thu Aug 12 2010 Kalev Lember <kalev@smartlink.ee> - 0.4.0-2
- Added missing phonon-devel and qt-webkit-devel deps (#623425)

* Wed Aug 11 2010 Kalev Lember <kalev@smartlink.ee> - 0.4.0-1
- Initial RPM release
