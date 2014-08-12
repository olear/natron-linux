#!/bin/sh
export LC_NUMERIC=C
export LD_LIBRARY_PATH=lib:$LD_LIBRARY_PATH
bin/Natron $*
