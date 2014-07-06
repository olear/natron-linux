#!/bin/sh
#
# Written by Ole Andre Rodlie <olear@dracolinux.org>
#

CWD=$(pwd)
TMP_PATH=$CWD/tmp
INSTALLER=$TMP_PATH/Natron-installer

repogen -v -c $INSTALLER/config/config.xml -p $INSTALLER/packages $CWD/repo || exit 1
