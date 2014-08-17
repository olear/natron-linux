Natron on Linux/BSD
===================

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

 - FreeBSD 10
 - PC-BSD 10


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

Support
=======

https://groups.google.com/forum/?hl=en#!forum/natron-vfx

Sources
=======

https://fxarena.net/natron/source/

Build on Linux
==============

Download CentOS 6.2 minimal and install.

 * http://mirror.nsc.liu.se/centos-store/6.2/isos/i386/CentOS-6.2-i386-minimal.iso
 * http://mirror.nsc.liu.se/centos-store/6.2/isos/x86_64/CentOS-6.2-x86_64-minimal.iso

Setup main repository.

```
rm -f /etc/yum.repos.d/CentOS-Base.repo
sed -i 's#baseurl=file:///media/CentOS/#baseurl=http://vault.centos.org/6.2/os/$basearch/#;s/enabled=0/enabled=1/;s/gpgcheck=1/gpgcheck=0/;/file:/d' /etc/yum.repos.d/CentOS-Media.repo
```

Install system tools.

```
yum -y install wget rsync git screen file
```

Add devtools repository.

```
wget http://people.centos.org/tru/devtools-1.1/devtools-1.1.repo -O /etc/yum.repos.d/devtools-1.1.repo
```

Install build essentials.

```
yum -y install devtoolset-1.1 gcc-c++ kernel-devel libX*devel fontconfig-devel freetype-devel zlib-devel *GL*devel *xcb*devel xorg*devel libdrm-devel mesa*devel *glut*devel dbus-devel xz patch bzip2-devel glib2-devel bison flex expat-devel scons libtool-ltdl-devel
```

Download build scripts.

```
git clone https://github.com/olear/natron-linux
```

Build SDK.

```
cd natron-linux
sh scripts/build-prep.sh
sh scripts/build-sdk.sh
```

Build Natron and core plugins.

```
sh scripts/build-release.sh
sh scripts/build-plugins-release.sh
```

Build extra plugins.

```
sh scripts/build-plugins-extra.sh
sh scripts/build-tuttle.sh
```

Build Natron setup/repository.

```
sh scripts/build-package-release.sh
```

Build Natron Bundle setup/repository.

```
sh scripts/build-package-bundle.sh
```

Build on FreeBSD
================

Download FreeBSD 10 and install.

 * ftp://ftp.freebsd.org/pub/FreeBSD/releases/amd64/amd64/ISO-IMAGES/10.0/FreeBSD-10.0-RELEASE-amd64-disc1.iso

Install system tools.

```
pkg install wget git bash gtar
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
sh scripts/build-release-freebsd.sh
sh scripts/build-plugins-release-freebsd.sh
```

Build Natron TGZ.

```
sh scripts/build-package-freebsd.sh
```

