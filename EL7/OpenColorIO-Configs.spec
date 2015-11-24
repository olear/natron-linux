Summary: Color Configurations for OpenColorIO
Name: OpenColorIO-Configs

Version: 20151117
Release: 1%{?dist}
License: BSD

Group: System Environment/Base
URL: https://github.com/MrKepzie/OpenColorIO-Configs

Source: %{name}-%{version}.tar.xz

# dont work, force with --target=noarch
BuildArch: noarch

BuildRoot: %{_tmppath}/%{name}-%{version}-root

%description
Color Configurations for OpenColorIO

%prep
%setup -q

%install
mkdir -p %{buildroot}/usr/share/OpenColorIO-Configs
cp -a * %{buildroot}/usr/share/OpenColorIO-Configs/

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-,root,root,-)
/usr/share/OpenColorIO-Configs
%doc README

%changelog
