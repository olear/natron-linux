Natron on Linux
===============

Scripts used to build and distribute [Natron](http://www.natron.fr) on Linux.

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

**Kubuntu:**

```
apt-get install librsvg2-2
```

Technical information
=====================

Minimum requirements for running Natron on Linux:

- Linux 2.6.18
- Glibc 2.12
- LibGCC 4.4
- Freetype
- Zlib
- Glib
- LibSM
- LibICE
- LibXrender
- Fontconfig
- LibXext
- LibX11
- Libxcb
- Libexpat
- LibXau
- Bzip2
- LibGL
- Pango
- librsvg

Most Linux installations since 2010 meet these requirements. Natron is compatible with the VFX Reference Platform CY2015.

Build server installation
=========================

 * Download http://mirror.nsc.liu.se/centos-store/6.4/isos/x86_64/CentOS-6.4-x86_64-minimal.iso (or http://mirror.nsc.liu.se/centos-store/6.4/isos/i386/CentOS-6.4-i386-minimal.iso)
 * Install ISO (remember to edit network)
 * Download https://github.com/olear/natron-linux/blob/master/include/scripts/setup-centos6.sh from another computer
 * Boot build server
 * Copy 'setup-centos6.sh' to server using SSH
 * login to build server as root
 * run 'setup-centos6.sh' (this may take a while)
 * git clone https://github.com/olear/natron-linux (in /root dir)
 * ln -sf /root/natron-linux/cron.sh /etc/cron.hourly/natron-cron.sh

Online repository
==================

When building third-party dependencies or the Natron binaries you can upload them to a server. 
For this to work you need to create a file named **repo.sh** next to *autobuild2.sh*, with for example the following content:

    #!/bin/sh

    REPO_DEST=user@host:/path
    REPO_URL=http://some.url
