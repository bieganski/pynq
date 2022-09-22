#!/bin/bash


# Following script was successfully tested on Ubuntu 22.04.

# To be run after `install_nextpnr.sh`.

# For some reason Amaranth HDL assumes chipdb to be under `nextpnr_dir`/xilinx-chipdb/xc7z020.bin,
# where `nextpnr_dir` is passed to Platform().build(nextpnr_dir=a/b/c).

set -eux

XILINX_CHIPDB_DIR=xilinx-chipdb
PARTNAME_FULL=xc7z020clg400-1
PARTNAME=xc`echo $PARTNAME_FULL | cut -d c -f 2`

NEXTPNR_DIR=nextpnr-xilinx
NEXTPNR_EXE=$NEXTPNR_DIR/$NEXTPNR_DIR

if ! [ -d $NEXTPNR_DIR ]; then
    echo "ERROR: not found $NEXTPNR_DIR repository present!"
    exit 1
fi

if ! [ -f $NEXTPNR_EXE ]; then
    echo "ERROR: could not found $NEXTPNR_EXE binary inside nextpnr-xilinx repository!"
    exit 1
fi

pushd $NEXTPNR_DIR > /dev/null


BBA_FPATH=$XILINX_CHIPDB_DIR/$PARTNAME.bba
BIN_FPATH=$XILINX_CHIPDB_DIR/$PARTNAME.bin

set -x
mkdir -p $XILINX_CHIPDB_DIR
pypy3 xilinx/python/bbaexport.py --device $PARTNAME_FULL --bba $XILINX_CHIPDB_DIR/$PARTNAME.bba
./bbasm --l $BBA_FPATH $BIN_FPATH
set +x

du -sh $BBA_FPATH
du -sh $BIN_FPATH

popd > /dev/null