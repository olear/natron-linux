#!/bin/sh
V=0.9.5
R=1
binarycreator -v -f -p natron/packages -c natron/config/config.xml Natron-$V-$R-linux64-installer.bin
sha1sum Natron-$V-$R-linux64-installer.bin > Natron-$V-$R-linux64-installer.sha1
