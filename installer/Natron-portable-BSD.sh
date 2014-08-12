#!/bin/sh
export LC_NUMERIC=C
export LD_LIBRARY_PATH=lib:$LD_LIBRARY_PATH
#export XDG_CACHE_HOME=/tmp
export XDG_DATA_HOME=.
export XDG_CONFIG_HOME=.
bin/Natron $*
