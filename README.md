Natron on Linux/BSD
===================
![Image Alt](https://github.com/olear/natron-linux/raw/master/misc/natron-screenshot-01.png)
[Natron](http://natron.inria.fr/) is an open source node-based digital compositing software. Similar to [Apple Shake](http://en.wikipedia.org/wiki/Apple_shake), [Foundry Nuke](http://en.wikipedia.org/wiki/Nuke_%28software%29) and [others](http://en.wikipedia.org/wiki/Category:Compositing_software).

[Digital compositing](http://en.wikipedia.org/wiki/Digital_compositing) is the process of digitally assembling multiple images to make a final image, typically for print, motion pictures or screen display. It is the evolution into the digital realm of optical film compositing.

![Image Alt](https://github.com/olear/natron-linux/raw/master/misc/natron-screenshot-02.png)

Requirements
============

 - i686/x86-64 compatible CPU
 - 2GB RAM+
 - OpenGL 2.0 or OpenGL 1.5 with the following extensions:
   - GL_ARB_texture_non_power_of_two
   - GL_ARB_shader_objects,
   - GL_ARB_vertex_buffer_object
   - GL_ARB_pixel_buffer_object
 - NVIDIA GPU recommended.


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

 - FreeBSD 10 (experimental)


Notes
=====

On some distros/OS Natron requires additional software to function.

**CentOS/RHEL/Fedora:**

```
yum install libGLU
```

**Ubuntu 10.04:**

```
apt-get install libxcb-shm0
```

**FreeBSD: (experimental)**

```
pkg install glew openimageio opencolorio expat qt4 boost-libs ffmpeg pixman xcb-util xcb-util-renderutil
```

Installation
============
Download the latest online [installer](https://fxarena.net/natron/Linux64/Natron-0.9-Online-Setup-Linux64.tgz). Extract the downloaded TGZ and run the installer.

![Image Alt](https://github.com/olear/natron-linux/raw/master/misc/natron-install-00.png)

![Image Alt](https://github.com/olear/natron-linux/raw/master/misc/natron-install-01.png)

![Image Alt](https://github.com/olear/natron-linux/raw/master/misc/natron-install-09.png)

Maintenance
===========

You can maintain your installation with the included maintenance tool.

![Image Alt](https://github.com/olear/natron-linux/raw/master/misc/natron-install-08.png)

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

under construction...

depends:glew gmake openimageio opencolorio expat qt4 boost-all ffmpeg cairo pkgconf. Rembember to remove cairo and replace with 12.
