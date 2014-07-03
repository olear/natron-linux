#!/bin/sh
export LC_NUMERIC=C
export LD_LIBRARY_PATH=lib:$LD_LIBRARY_PATH
export OCIO=share/OpenColorIO-Configs/nuke-default/config.ocio
bin/NatronRenderer $*
