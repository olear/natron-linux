#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

export LC_NUMERIC=C
export LD_LIBRARY_PATH=$DIR/lib:$LD_LIBRARY_PATH

#export PYTHON_HOME=$DIR
#export PYTHON_PATH=$DIR/lib/python3.4

#if [ "$1" == "-update" ] && [ -x $DIR/NatronSetup ]; then
#  $DIR/NatronSetup --updater
#fi

#if [ "$1" == "-portable" ]; then
#  #export XDG_CACHE_HOME=/tmp
#  export XDG_DATA_HOME=$DIR
#  export XDG_CONFIG_HOME=$DIR
#fi

if [ "$1" == "-debug" ]; then
  export SEGFAULT_SIGNALS="all"
  catchsegv $DIR/bin/Natron.debug -style fusion "$*"
else
  $DIR/bin/Natron -style fusion "$*"
fi
