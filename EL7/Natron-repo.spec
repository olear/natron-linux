Name:           Natron-repo
Version:        2.0
Release:        1%{dist}
Summary:        Natron repository
Group:          System Environment/Base
License:        GPLv2
Source0:	Natron.repo
BuildArch:	noarch
URL:		http://natron.fr

%description
Natron repository

%install
mkdir -p $RPM_BUILD_ROOT/etc/yum.repos.d
install -m 644 %{SOURCE0} $RPM_BUILD_ROOT/etc/yum.repos.d/Natron.repo

%files
%defattr(-,root,root)
%config %attr(0644,root,root) /etc/yum.repos.d/Natron.repo

%changelog

