#!/bin/sh

GIT_NATRON=https://github.com/MrKepzie/Natron.git
GIT_IO=https://github.com/MrKepzie/openfx-io.git
GIT_MISC=https://github.com/devernay/openfx-misc.git

CWD=$(pwd)
TMP_PATH=$CWD/tmp
DATE=$(date +%Y%m%d)

if [ ! -d $TMP_PATH ]; then
  mkdir -p $TMP_PATH || exit 1
else
  rm -rf $TMP_PATH || exit 1
  mkdir -p $TMP_PATH || exit 1
fi

cd $TMP_PATH || exit 1
git clone $GIT_IO || exit 1
cd openfx-io || exit 1
git submodule update -i --recursive || exit 1
find . -type d -name .git -exec rm -rf {} \;
cd .. || exit 1
mv openfx-io openfx-io-$DATE || exit 1
tar cvvzf openfx-io-$DATE.tar.gz openfx-io-$DATE || exit 1
mv openfx-io-$DATE.tar.gz $CWD/src/ || exit 1

cd $TMP_PATH || exit 1
git clone $GIT_MISC || exit 1
cd openfx-misc || exit 1
git submodule update -i --recursive || exit 1
find . -type d -name .git -exec rm -rf {} \;
cd .. || exit 1
mv openfx-misc openfx-misc-$DATE || exit 1
tar cvvzf openfx-misc-$DATE.tar.gz openfx-misc-$DATE || exit 1
mv openfx-misc-$DATE.tar.gz $CWD/src/ || exit 1

cd $TMP_PATH || exit 1
git clone $GIT_NATRON || exit 1
cd Natron || exit 1
git submodule update -i --recursive || exit 1
find . -type d -name .git -exec rm -rf {} \;
#NATRON_V=$(cat LATEST_VERSION.txt | awk '{print $4}')
if [ "$NATRON_V" == "" ]; then
  NATRON_V=$DATE
fi
cd .. || exit 1
mv Natron Natron-$NATRON_V || exit 1
tar cvvzf Natron-$NATRON_V.tar.gz Natron-$NATRON_V || exit 1
mv Natron-$NATRON_V.tar.gz $CWD/src/ || exit 1

