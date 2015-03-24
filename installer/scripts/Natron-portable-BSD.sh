#!/bin/sh
export LC_NUMERIC=C
DIR="$(cd "$(dirname "$0")" && pwd)"
export LD_LIBRARY_PATH=$DIR/lib:$LD_LIBRARY_PATH
#export XDG_CACHE_HOME=/tmp
export XDG_DATA_HOME=.
export XDG_CONFIG_HOME=.
$DIR/bin/Natron $*
