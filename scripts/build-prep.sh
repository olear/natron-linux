#!/bin/sh
# Prepare CentOS/RHEL for Natron build
# Written by Ole Andre Rodlie <olear@fxarena.net>

if [ ! -f /etc/yum.repos.d/devtools-1.1.repo ]; then
  wget http://people.centos.org/tru/devtools-1.1/devtools-1.1.repo -O /etc/yum.repos.d/devtools-1.1.repo
  yum -y install devtoolset-1.1
fi

scl enable devtoolset-1.1 bash
