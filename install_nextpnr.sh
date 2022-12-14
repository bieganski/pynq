#!/bin/bash

# Following script was successfully tested on Ubuntu 22.04.


set -eu

# Prerequisites.
sudo apt-get install libboost-all-dev
sudo apt install libeigen3-dev

GITHUB_URL=https://github.com/gatecat/nextpnr-xilinx
DIRNAME=`basename $GITHUB_URL`


if [ -d "$DIRNAME" ]; then
    echo "$DIRNAME exists, skipping download.."
else
    git clone "$GITHUB_URL"
fi

NUM_CORES=`nproc --ignore 2`

pushd "$DIRNAME"
git submodule init
git submodule update
cmake -DARCH=xilinx . 
make -j$NUM_CORES
popd

TOOLPATH=$DIRNAME/$DIRNAME


if ! [[ -f $TOOLPATH ]]; then
    echo "== ERROR: Could not find $TOOLPATH, althought it should have been installed!"
    exit 1
else
    echo "== OK, $TOOLPATH binary was compiled! Add it to your PATH via following command:"
    echo -n ' $ export PATH=$PATH:'
    echo `dirname $(realpath $TOOLPATH)`
fi

# Amaranth's Platform.build() creates `build/build_top.sh` script, that invokes series of 
# yosys and nextpnr scripts. Some of them assume `prjxray-db` to be cloned inside `nextpnr-xilinx`.

pushd $DIRNAME > /dev/null

PRJXRAY_URL=https://github.com/f4pga/prjxray-db
PRJXRAY_DIRNAME=`basename $PRJXRAY_URL`
if ! [ -d $PRJXRAY_DIRNAME ]; then
    echo "== Downloading prjxray-db, needed for routing.."
    git clone $PRJXRAY_URL
else
    echo "== $PRJXRAY_DIRNAME found inside $DIRNAME! Skipping download.."

fi

popd > /dev/null