%define debug_package %{nil}

Name:           Natron
Version:        0.9.5
Release:        2
Summary:        Node-graph based compositing software
License:        MPLv2
Source0:	Natron-%{version}-%{release}-beta-qt4-linux64.tgz
Group:		Applications/Multimedia
URL:		http://natron.inria.fr
Packager:	Ole Andre Rodlie <olear@dracolinux.org>

AutoReqProv: no
Requires:libGLU

%description
Node-graph based compositing software.

%prep
%setup -q -n Natron-%{version}-%{release}-beta-qt4-linux64

%build
echo OK

%install
rm -rf $RPM_BUILD_ROOT

mkdir -p $RPM_BUILD_ROOT/opt/Natron-%{version} $RPM_BUILD_ROOT/usr/share/applications $RPM_BUILD_ROOT/usr/share/pixmaps $RPM_BUILD_ROOT/usr/bin
cp share/pixmaps/natronIcon256_linux.png $RPM_BUILD_ROOT/usr/share/pixmaps/
cp share/applications/natron.desktop $RPM_BUILD_ROOT/usr/share/applications/

cat Natron | sed 's#=share#=/opt/Natron-0.9.5#;s#=lib#=/opt/Natron-0.9.5/lib#;s#bin/Natron#/opt/Natron-0.9.5/bin/Natron#' > $RPM_BUILD_ROOT/usr/bin/Natron
cat NatronRenderer | sed 's#=share#=/opt/Natron-0.9.5#;s#=lib#=/opt/Natron-0.9.5/lib#;s#bin/Natron#/opt/Natron-0.9.5/bin/Natron#' > $RPM_BUILD_ROOT/usr/bin/NatronRenderer
rm -rf Install.sh Uninstall.sh

mv * $RPM_BUILD_ROOT/opt/Natron-%{version}/

chmod +x $RPM_BUILD_ROOT/usr/bin/*

%files
%defattr(-,root,root)
/opt/Natron-%{version}/*
/usr/bin/*
/usr/share/applications/natron.desktop
/usr/share/pixmaps/natronIcon256_linux.png

%changelog
* Tue Jul 01 2014 Ole Andre Rodlie <olear@dracolinux.org> 0.9.5-2
- Sync with upstream

* Tue Jun 24 2014 Ole Andre Rodlie <olear@fxarena.net> 0.9.3-2
- Rebuild against third-party software
- Fix depends in RPM
- Added ffmpeg binary
- Added stylesheet patch for toolbar
- Create universal bins/libs

* Mon Jun 23 2014 Ole Andre Rodlie <olear@fxarena.net> 0.9.3-1
- Initial RPM release
