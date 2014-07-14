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

if [ -f $DIR/share/OpenColorIO-Configs/nuke-default/config.ocio ]; then
  export OCIO=$DIR/share/OpenColorIO-Configs/nuke-default/config.ocio
fi

export XDG_CACHE_HOME=/tmp
export XDG_DATA_HOME=$DIR
export XDG_CONFIG_HOME=$DIR

$DIR/bin/Natron $*