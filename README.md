Natron on Linux and FreeBSD
===========================

Build scripts for Natron on Linux and FreeBSD. **Not** for regular users, only developers and testers.

TODO
====

 * Clean up
 * Minimize depends
 * Support for CentOS/RHEL 5 and Debian 6
 * Add tutorials/examples
 * Port installer to win32

Verified Compatibility
======================

 - CentOS/RHEL 6.2+
 - Fedora 14+
 - Ubuntu 10.04+
 - Debian 7+
 - openSUSE 12+
 - Mageia 2+
 - Slackware 13.37+
 - Arch Linux 2011.08.19+
 - Gentoo 11.0+
 - Linux Mint 10+
 - PCLinuxOS 2011.09+
 - FreeBSD 10+
 - PC-BSD 10+

Latest versions are of course supported, we only print lowest possible version.

Deployment Notes
================

A normal desktop/X installation should not need any additional software, but some do:

**CentOS/RHEL/Fedora:**

```
yum install libGLU
```

**Ubuntu 10.04:**

```
apt-get install libxcb-shm0
```

**FreeBSD/PC-BSD:**

```
pkg install glew openimageio opencolorio expat qt4-libs boost-libs ffmpeg pixman
```

Support
=======

https://groups.google.com/forum/?hl=en#!forum/natron-vfx

Technical information
=====================

Required for running Natron on your computer:

- Linux 2.6.18+
- Glibc 2.11+
- Libgcc/libstdc++ 4.4+
- Freetype 2.3+
- Zlib 1.2+
- Glib 2.26+
- LibSM 1.2.1+
- LibICE 1.0.6+
- LibXrender 0.9.7+
- Fontconfig 2.8.0+
- LibXext 1.3.1+
- LibX11 1.5.0+
- Libxcb 1.8.1+ 
- Libexpat 2.0.1+
- LibXau 1.0.6+
- LibGL

Most Linux desktop/X installations since 2010 meet these requirements.

Build server setup (Linux)
==========================

 * http://mirror.nsc.liu.se/centos-store/6.2/isos/i386/CentOS-6.2-i386-minimal.iso
 * http://mirror.nsc.liu.se/centos-store/6.2/isos/x86_64/CentOS-6.2-x86_64-minimal.iso

```
rm -f /etc/yum.repos.d/CentOS-Base.repo
sed -i 's#baseurl=file:///media/CentOS/#baseurl=http://vault.centos.org/6.2/os/$basearch/#;s/enabled=0/enabled=1/;s/gpgcheck=1/gpgcheck=0/;/file:/d' /etc/yum.repos.d/CentOS-Media.repo
yum -y install git
git clone https://github.com/olear/natron-linux
```

```
cd natron-linux
sh scripts/setup-centos.sh
sh scripts/build-prep.sh
sh scripts/build-sdk.sh
```

Build server setup (FreeBSD)
============================

 * ftp://ftp.freebsd.org/pub/FreeBSD/releases/amd64/amd64/ISO-IMAGES/10.0/FreeBSD-10.0-RELEASE-amd64-disc1.iso
 * ftp://ftp.freebsd.org/pub/FreeBSD/releases/i386/i386/ISO-IMAGES/10.0/FreeBSD-10.0-RELEASE-i386-disc1.iso

```
pkg install glew gmake openimageio opencolorio expat qt4 boost-all ffmpeg pixman xcb-util xcb-util-renderutil pkgconf
git clone https://github.com/olear/natron-linux
```

```
cd natron-linux
sh scripts/build-sdk-freebsd.sh
```

Build server scripts
====================
```
sh scripts/build-release.sh (workshop)
sh scripts/build-plugins.sh (workshop)
sh scripts/build-package.sh (workshop)
```

