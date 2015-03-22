Natron on Linux/BSD
===================

Build scripts for Natron on Linux, FreeBSD, Windows (TODO, own branch).

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


Notes
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
sh scripts/build-sdk.sh
```

Build Natron and core plugins.

```
sh scripts/build-release.sh (workshop)
sh scripts/build-plugins.sh (workshop)
```

Build Natron setup/repository.

```
sh scripts/build-package.sh (workshop)
```

Build on FreeBSD
================

Download FreeBSD 10 and install.

 * ftp://ftp.freebsd.org/pub/FreeBSD/releases/amd64/amd64/ISO-IMAGES/10.0/FreeBSD-10.0-RELEASE-amd64-disc1.iso
 * ftp://ftp.freebsd.org/pub/FreeBSD/releases/i386/i386/ISO-IMAGES/10.0/FreeBSD-10.0-RELEASE-i386-disc1.iso

Setup:
```
pkg install glew gmake openimageio opencolorio expat qt4 boost-all ffmpeg pixman xcb-util xcb-util-renderutil pkgconf
git clone https://github.com/olear/natron-linux
```

Build SDK:

```
cd natron-linux
sh scripts/build-sdk.sh
```

Build Natron and core plugins:

```
sh scripts/build-release.sh (workshop)
sh scripts/build-plugins.sh (workshop)
```

Build Natron setup/repository:

```
sh scripts/build-package.sh (workshop)
```

