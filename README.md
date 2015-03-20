Natron on Linux/BSD
===================

Build scripts for Natron on Linux, FreeBSD, Windows (TODO, own branch).

Releases
========

 * Latest Workshop build: https://github.com/olear/natron-linux/releases/tag/20150320
 * Latest Stable build: N/A

Linux
=====

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

BSD
===

 - FreeBSD 10+
 - PC-BSD 10+


Notes (updated?)
=====

On some distros Natron requires additional software to function.

**CentOS/RHEL/Fedora:**

```
yum install libGLU
```

**Ubuntu 10.04:**

```
apt-get install libxcb-shm0
```

**FreeBSD:**

```
pkg install glew openimageio opencolorio expat qt4 boost-libs ffmpeg pixman
```

**PC-BSD:**

```
pkg install glew openimageio
```

**NOTE!** You **must** run the Natron installer as root on FreeBSD/PC-BSD.

Support
=======

https://groups.google.com/forum/?hl=en#!forum/natron-vfx

Sources
=======

http://snapshots.natronvfx.com/source

Build on Linux
==============

Download CentOS 6.2 minimal and install.

 * http://mirror.nsc.liu.se/centos-store/6.2/isos/i386/CentOS-6.2-i386-minimal.iso
 * http://mirror.nsc.liu.se/centos-store/6.2/isos/x86_64/CentOS-6.2-x86_64-minimal.iso

Setup:

```
rm -f /etc/yum.repos.d/CentOS-Base.repo
sed -i 's#baseurl=file:///media/CentOS/#baseurl=http://vault.centos.org/6.2/os/$basearch/#;s/enabled=0/enabled=1/;s/gpgcheck=1/gpgcheck=0/;/file:/d' /etc/yum.repos.d/CentOS-Media.repo
yum -y install wget rsync git screen file
wget http://people.centos.org/tru/devtools-1.1/devtools-1.1.repo -O /etc/yum.repos.d/devtools-1.1.repo
yum -y install devtoolset-1.1 gcc-c++ kernel-devel libX*devel fontconfig-devel freetype-devel zlib-devel *GL*devel *xcb*devel xorg*devel libdrm-devel mesa*devel *glut*devel dbus-devel xz patch bzip2-devel glib2-devel bison flex expat-devel scons libtool-ltdl-devel
git clone https://github.com/olear/natron-linux
```

Build SDK:

```
cd natron-linux
sh scripts/build-prep.sh
sh scripts/build-sdk.sh (workshop)
```

If you use a precompiled tarball, just extract content to /opt.

 * https://github.com/olear/natron-linux/releases/download/20150320/Natron-2.0-Linux-x86_64-SDK.tar.xz


Build Natron and core plugins.

```
sh scripts/build-release.sh (workshop)
sh scripts/build-plugins.sh (workshop)
```

Build Natron setup/repository.

```
sh scripts/build-package.sh (workshop)
```

Build on FreeBSD (outdated)
================

Download FreeBSD 10 and install.

 * ftp://ftp.freebsd.org/pub/FreeBSD/releases/amd64/amd64/ISO-IMAGES/10.0/FreeBSD-10.0-RELEASE-amd64-disc1.iso

Install system tools.

```
pkg install wget git
```

Install build essentials.

```
pkg install glew gmake openimageio opencolorio expat qt4 boost-all ffmpeg pixman xcb-util xcb-util-renderutil pkgconf
```

Download build scripts.

```
git clone https://github.com/olear/natron-linux
```

Build SDK. Only needed until FreeBSD adds Cairo 12+.

```
cd natron-linux
sh scripts/build-sdk.sh
```

Build Natron and core plugins.

```
sh scripts/build-release.sh (workshop)
sh scripts/build-plugins.sh (workshop)
```

Build Natron setup/repository

```
sh scripts/build-package.sh (workshop)
```

