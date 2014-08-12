#!/usr/local/bin/bash
#
# Written by Ole Andre Rodlie <olear@dracolinux.org>
#

VERSION=20140812.1

CWD=$(pwd)
TMP=$CWD/tmp
INSTALL_PATH=/usr/local
TGZ=Natron_FreeBSD_PC-BSD_workshop_x86-64bit_v$VERSION

rm -rf $TMP/$TGZ

mkdir -p $TMP/$TGZ/bin $TMP/$TGZ/lib $TMP/$TGZ/share $TMP/$TGZ/docs || exit 1

cp -av $INSTALL_PATH/bin/Natron* $TMP/$TGZ/bin/ || exit 1
cp -av $INSTALL_PATH/share/OpenColor* $TMP/$TGZ/share/ || exit 1
cp -av $INSTALL_PATH/docs/* $TMP/$TGZ/docs/ || exit 1
cp -av $INSTALL_PATH/lib/libcairo.so.11202 $TMP/$TGZ/lib/ || exit 1
rm -rf $TMP/$TGZ/docs/cairo/*GPL*
cp -av $INSTALL_PATH/Plugins $TMP/$TGZ/ || exit 1

# PC-BSD compat
cp -av $INSTALL_PATH/lib/libOpenImageIO.so.1.4.9 $TMP/$TGZ/lib/libOpenImageIO.so.1.4 || exit 1

cat $CWD/installer/Natron-BSD.sh > $TMP/$TGZ/Natron || exit 1
cat $CWD/installer/Natron-BSD.sh | sed "s#bin/Natron#bin/NatronRenderer#" > $TMP/$TGZ/NatronRenderer || exit 1

chmod +x $TMP/$TGZ/Natron* || exit 1
cat $CWD/installer/README_FREEBSD.txt > $TMP/$TGZ/README_FIRST.TXT || exit 1
#chmod -R 755 $TMP/$TGZ/Plugins || exit 1
cd $TMP || exit 1
gtar cvvzf $TGZ.tgz $TGZ || exit 1
echo "Done!"
