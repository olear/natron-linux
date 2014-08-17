#!/bin/sh
if [ -z "$ARCH" ]; then
  case "$( uname -m )" in
    i?86) export ARCH=i686 ;;
       *) export ARCH=$( uname -m ) ;;
  esac
fi
if [ "$ARCH" = "i686" ]; then
  BIT=32
elif [ "$ARCH" = "x86_64" ]; then
  BIT=64
fi

if [ -d repo/linux$BIT/1.0/releases ]; then
  rsync -avz -e ssh repo/linux$BIT/1.0/releases/ ${1}@frs.sourceforge.net:/home/frs/project/dracolinux/natron/linux$BIT/1.0/releases/
fi

if [ -d repo/linux$BIT/1.0/repo ]; then
  rsync -avz -e ssh --delete repo/linux$BIT/1.0/repo/ ${1}@frs.sourceforge.net:/home/frs/project/dracolinux/natron/linux$BIT/1.0/repo/
fi

if [ -d repo/linux$BIT/workshop ]; then
  rsync -avz -e ssh --delete repo/linux$BIT/workshop/ ${1}@frs.sourceforge.net:/home/frs/project/dracolinux/natron/linux$BIT/workshop/
fi
