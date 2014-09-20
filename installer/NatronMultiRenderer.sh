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

CORES=$(cat /proc/cpuinfo | sed '/siblings/!d' | awk '{print $3}' |  head -1)
FRAMES=$(sed -n '/lastFrame</,/<\/HasMaster/p' $1 | sed '/Value/!d;s/</ /g;s/>/ /g' | awk '{print $2}' | head -1)
CORE_TICK=$(echo "$FRAMES/$CORES"|bc)
TICK_COUNTER=0
FRAME_COUNTER=0
CORE_COUNTER=1

while [ $FRAME_COUNTER -le $FRAMES ]; do
  if [ $TICK_COUNTER -eq $CORE_TICK ]; then
    if [ $CORE_COUNTER == 1 ]; then
      FIRST_FRAME=0
    else
      FIRST_FRAME=$(echo "${FRAME_COUNTER}-$CORE_TICK+1"|bc)
    fi
    if [ $CORE_COUNTER == $CORES ]; then
      LAST_FRAME=$FRAMES
    else
      LAST_FRAME=$FRAME_COUNTER
    fi
    echo "Starting rendering thread #$CORE_COUNTER"
    echo "Command: NatronRenderer $1 -t $FIRST_FRAME-$LAST_FRAME &"
    TICK_COUNTER=0
    CORE_COUNTER=$(( CORE_COUNTER+1 ))
  fi
  TICK_COUNTER=$(( TICK_COUNTER+1 ))
  FRAME_COUNTER=$(( FRAME_COUNTER+1 ))
done
