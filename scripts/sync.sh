#!/bin/sh
if [ -z "$ARCH" ]; then
  case "$( uname -m )" in
    i?86) export ARCH=i686 ;;
    amd64) export ARCH=x86_64 ;;
       *) export ARCH=$( uname -m ) ;;
  esac
fi
if [ "$ARCH" = "i686" ]; then
  BIT=32
elif [ "$ARCH" = "x86_64" ]; then
  BIT=64
fi
OS=$(uname -o)

if [ "$OS" == "FreeBSD" ]; then
  SF_OS=freebsd$BIT
else
  SF_OS=linux$BIT
fi

if [ -d repo/$SF_OS/1.0/releases ]; then
  rsync -avz -e ssh repo/$SF_OS/1.0/releases/ ${1}@frs.sourceforge.net:/home/frs/project/dracolinux/natron/$SF_OS/1.0/releases/
fi

if [ -d repo/$SF_OS/1.0/repo ]; then
  rsync -avz -e ssh --delete repo/$SF_OS/1.0/repo/ ${1}@frs.sourceforge.net:/home/frs/project/dracolinux/natron/$SF_OS/1.0/repo/
fi

if [ -d repo/$SF_OS/workshop ]; then
  rsync -avz -e ssh --delete repo/$SF_OS/workshop/ ${1}@frs.sourceforge.net:/home/frs/project/dracolinux/natron/$SF_OS/workshop/
fi
