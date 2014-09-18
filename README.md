Natron on Linux/BSD
===================

Linux
=====

 - CentOS/RHEL 6.2+
   - Tested 6.2-6.6
   - Tested 7.0
 - Fedora 14+
   - Tested 14-21
 - Ubuntu 10.04+
   - Tested 10.04/12.04/14.04
 - Debian 7+
   - Tested 7-7.5
 - openSUSE 12+
   - Tested 12-13.x
 - Mageia 2+
   - Tested 2-4.x
 - Slackware 13.37+
   - Tested 13.37-14.x
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

Update from 0.96 or lower
=========================

Updating from versions lower than 1.0.0 RC requires changes to the repository settings. Launch 'MaintenanceTool', press 'Package Manager', then press 'Settings' and select the 'Repositories' tab. Deselect the default repository,  select 'User defined repositories', and press add. The new URL is http://repo.natronvfx.com/OS (OS=linux64|linux32|freebsd64|freebsd32).

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
sh scripts/build-release.sh (workshop)
sh scripts/build-plugins.sh (workshop)
```

Build extra plugins.

```
sh scripts/build-plugins-extra.sh
sh scripts/build-tuttle.sh
```

Build Natron setup/repository.

```
sh scripts/build-package.sh (workshop)
```

Build on FreeBSD
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

