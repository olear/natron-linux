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
export OCIO=$DIR/share/OpenColorIO-Configs/nuke-default/config.ocio

$DIR/bin/Natron $*
