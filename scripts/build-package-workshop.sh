#!/bin/sh
#
# Build installers and repo for Natron Linux64
# Written by Ole Andre Rodlie <olear@dracolinux.org>
#

SDK_VERSION=0.9
SNAPSHOT=20140714.1

DATE=$(date +%Y-%m-%d)
DATE_NUM=$(echo $DATE | sed 's/-//g')

CWD=$(pwd)
INSTALL_PATH=/opt/Natron-$SDK_VERSION
TMP_PATH=$CWD/tmp

if [ ! -d $TMP_PATH ]; then
  mkdir -p $TMP_PATH || exit 1
else
  rm -rf $TMP_PATH || exit 1
  mkdir -p $TMP_PATH || exit 1
fi

# SETUP
INSTALLER=$TMP_PATH/Natron-installer
XML=$CWD/installer/xml
QS=$CWD/installer/qs

mkdir -p $INSTALLER/{config,packages} || exit 1
cat $CWD/installer/config/config.xml > $INSTALLER/config/config.xml || exit 1
cp $CWD/installer/config/*.png $INSTALLER/config/ || exit 1

# WORKSHOP
WORKSHOP_VERSION=$SNAPSHOT
WORKSHOP_PATH=$INSTALLER/packages/fr.inria.workshop
mkdir -p $WORKSHOP_PATH/meta $WORKSHOP_PATH/data/docs/natron $WORKSHOP_PATH/data/bin || exit 1
cat $XML/workshop.xml | sed "s/_VERSION_/${WORKSHOP_VERSION}/;s/_DATE_/${DATE}/" > $WORKSHOP_PATH/meta/package.xml || exit 1
cat $QS/workshop.qs > $WORKSHOP_PATH/meta/installscript.qs || exit 1
cp -a $INSTALL_PATH/docs/natron $WORKSHOP_PATH/data/docs/natron-workshop || exit 1
cat $WORKSHOP_PATH/data/docs/natron-workshop/LICENSE.txt > $WORKSHOP_PATH/meta/license.txt || exit 1
cp $INSTALL_PATH/bin/NatronWS $INSTALL_PATH/bin/NatronRendererWS $WORKSHOP_PATH/data/bin/ || exit 1
strip -s $WORKSHOP_PATH/data/bin/*
cat $CWD/installer/Natron.sh | sed "s#bin/Natron#bin/NatronWS#" > $WORKSHOP_PATH/data/NatronWS || exit 1
cat $CWD/installer/Natron.sh | sed "s#bin/Natron#bin/NatronRendererWS#" > $WORKSHOP_PATH/data/NatronRendererWS || exit 1
chmod +x $WORKSHOP_PATH/data/NatronWS $WORKSHOP_PATH/data/NatronRendererWS || exit 1

$INSTALL_PATH/bin/repogen -v --update-new-components -p $INSTALLER/packages -c $INSTALLER/config/config.xml $CWD/repo/Linux64 || exit 1
