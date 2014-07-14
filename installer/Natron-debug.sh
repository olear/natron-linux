#!/bin/bash
export LC_NUMERIC=C

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

export LD_LIBRARY_PATH=$DIR/lib:$LD_LIBRARY_PATH

if [ -f $DIR/share/OpenColorIO-Configs/nuke-default/config.ocio ]; then
  export OCIO=$DIR/share/OpenColorIO-Configs/nuke-default/config.ocio
fi

BIN=$DIR/bin/Natron

if [ "${1}" = "-debug" ]; then
  if [ -f ${BIN}.debug ]; then
    BIN=${BIN}.debug
    echo "Running Natron in debug mode:"
    echo
    echo "LC_NUMERIC=${LC_NUMERIC}"
    echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"
    echo "OCIO=${OCIO}"
    echo
  fi
fi

$BIN $*
