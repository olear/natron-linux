Natron on Linux/FreeBSD
=======================

TODO
====

Todo list before v2.

 * Minimize depends (see tech info)
 * Support for CentOS/RHEL 5 and Debian 6
 * Port installer to win32
 * Merge 32bit and 64bit build
 * installer https support (low pri)

Installation Notes
==================

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

Most Linux desktop/X installations since 2010 meet these requirements.

Scripts
=======

```
Copyright (c) 2014-2015, Ole-André Rodlie <olear@fxarena.net>
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```
