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

if [ -f $DIR/bin/python3.4 ]; then
  export PYTHON_HOME=$DIR
  export PATH=$DIR/bin:$PATH
fi
if [ -f $DIR/lib/python3.4 ]; then
  export PYTHON_PATH=$DIR/lib/python3.4
fi

#export XDG_CACHE_HOME=/tmp
export XDG_DATA_HOME=$DIR
export XDG_CONFIG_HOME=$DIR

$DIR/bin/Natron -style fusion $*
