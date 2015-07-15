Natron on Linux
===============

Scripts used to build and distribute Natron on Linux.

Binary installation Notes
=========================

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

Minimum requirements for running Natron on Linux:

- Linux 2.6.18
- Glibc 2.11
- LibGCC 4.4
- Freetype 2.3 x
- Zlib 1.2 x
- Glib 2.26 x
- LibSM 1.2.1
- LibICE 1.0.6
- LibXrender 0.9.7
- Fontconfig 2.8.0 x
- LibXext 1.3.1
- LibX11 1.5.0
- Libxcb 1.8.1 x
- Libexpat 2.0.1 x
- LibXau 1.0.6
- Bzip2 1.0 x
- LibGL
- Pango
- librsvg
- libxml2

Most Linux desktop/X installations since 2010 meet these requirements.
