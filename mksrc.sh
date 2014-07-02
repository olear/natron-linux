#!/bin/sh
#

# Dist files
GIT_NATRON=https://github.com/MrKepzie/Natron.git

# Natron version
VERSION=0.9.5
GIT_V=RB-0.9

# Setup
CWD=$(pwd)
TMP_PATH=$CWD/tmp

if [ ! -d $TMP_PATH ]; then
  mkdir -p $TMP_PATH || exit 1
else
  rm -rf $TMP_PATH || exit 1
  mkdir -p $TMP_PATH || exit 1
fi

cd $TMP_PATH || exit 1
git clone $GIT_NATRON || exit 1
cd Natron || exit 1
git checkout ${GIT_V} || exit 1
git submodule update -i --recursive || exit 1
chown root:root -R *
find . -type d -name .git -exec rm -rf {} \;
cd .. || exit 1
mv Natron Natron-$VERSION || exit 1
tar cvvzf Natron-$VERSION.tar.gz Natron-$VERSION || exit 1
