Name:           Natron
Version:        0.9.5
Release:        4
Summary:        Node-graph based compositing software
License:        MPLv2
Source:		Natron-%{version}.tar.gz
Source1:	config.pri
Source2:	natron.desktop
#Source3:	stylefix.diff
Group:		Applications/Multimedia
URL:		http://natron.inria.fr
Packager:	Ole Andre Rodlie <olear@dracolinux.org>

#AutoReqProv: no

%if 0%{?fedora} || 0%{?rhel_version} || 0%{?centos_version}
BuildRequires: glibc-devel qt-devel boost-devel cairo-devel libGLU-devel gcc-c++
%endif

%if 0%{?fedora}
BuildRequires: glew-devel
%endif

%if 0%{?rhel_version} || 0%{?centos_version}
Source4: glew-1.5.5.tgz
Source5: glew_fix.diff
BuildRequires: libXmu-devel
%endif

# OpenImageIO-devel OpenColorIO-devel
#Provides:
#Requires:

%description
Node-graph based compositing software.

%prep
%setup -q
#patch -p0 < %{SOURCE3}

%if 0%{?rhel_version} || 0%{?centos_version}
patch -p0 < %{SOURCE5}
%endif

%build
cat %{SOURCE1} > config.pri

%if 0%{?rhel_version} || 0%{?centos_version}
tar xvf %{SOURCE4}
cd glew-1.5.5
make
rm lib/*so*
cd ..
echo "INCLUDEPATH+=%{_builddir}/%{name}-%{version}/glew-1.5.5/include" >> config.pri
echo "LIBS+=-L%{_builddir}/%{name}-%{version}/glew-1.5.5/lib" >> config.pri
echo "LIBS+=-lGLEW" >> config.pri
%endif


mkdir build
cd build
qmake-qt4 CONFIG+=release DEFINES+=QT_NO_DEBUG_OUTPUT -r ../Project.pro 
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
cd build
#make INSTALL_ROOT=$RPM_BUILD_ROOT install
mkdir -p $RPM_BUILD_ROOT/%{_datarootdir} $RPM_BUILD_ROOT/%{_bindir} $RPM_BUILD_ROOT/%{_docdir}/%{name}-%{version} $RPM_BUILD_ROOT/%{_datarootdir}/{pixmaps,applications}

cp -a ../Gui/Resources/OpenColorIO-Configs $RPM_BUILD_ROOT/%{_datarootdir}
cp App/Natron Renderer/NatronRenderer $RPM_BUILD_ROOT/%{_bindir}/
cp ../Documentation/* ../*.txt ../README.md $RPM_BUILD_ROOT/%{_docdir}/%{name}-%{version}/
cp ../Gui/Resources/Images/natronIcon256_linux.png $RPM_BUILD_ROOT/%{_datarootdir}/pixmaps/
cat %{SOURCE2} > $RPM_BUILD_ROOT/%{_datarootdir}/applications/Natron.desktop 

%files
%defattr(-,root,root)
%{_bindir}/Natron
%{_bindir}/NatronRenderer
%{_datarootdir}/OpenColorIO-Configs/*
%{_datarootdir}/pixmaps/natronIcon256_linux.png
%{_datarootdir}/applications/Natron.desktop
%{_docdir}/%{name}-%{version}/*

%changelog
* Tue Jul 01 2014 Ole Andre Rodlie <olear@dracolinux.org> 0.9.5-4
- Sync with upstream

