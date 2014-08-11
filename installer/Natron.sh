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

if [ -f $DIR/bin/python2.7 ]; then
  export PYTHON_HOME=$DIR
  export PATH=$DIR/bin:$PATH
fi
if [ -f $DIR/lib/python2.7 ]; then
  export PYTHON_PATH=$DIR/lib/python2.7
fi

if [ "$1" == "-debug" ]; then
  $DIR/bin/Natron.debug $*
else
  $DIR/bin/Natron $*
fi
