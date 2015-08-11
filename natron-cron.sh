#!/bin/sh
scl enable devtoolset-1.1 - << \EOF
cd /root/natron-linux || exit 1
bash autobuild2.sh >/tmp/natron-build.log 2>&1
EOF
