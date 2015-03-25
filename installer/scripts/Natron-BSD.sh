#!/bin/sh
export LC_NUMERIC=C
DIR="$(cd "$(dirname "$0")" && pwd)"
export LD_LIBRARY_PATH=$DIR/lib:$LD_LIBRARY_PATH
$DIR/bin/Natron "$*"
